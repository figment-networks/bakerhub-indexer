require "task_lock"

task sync_governance: :environment do
  $stdout.sync = true
  TaskLock.with_lock!(:sync_governance) do
    Rails.logger.debug "Setting Tezos Chain"
    chains = Tezos::Chain.all
    if chains.empty?
      Rails.logger.debug "No chain synced, run sync.rake before sync_governance.rake"
      next
    end

    chains.each do |chain|
      rpc            = Tezos::Rpc.new(chain)
      start_block    = 2
      meta           = rpc.get("blocks/head/metadata")
      latest_block   = meta["level_info"].present? ? meta["level_info"]["level"] : meta["level"]["level"]
      current_period = meta["voting_period_info"].present? ? meta["voting_period_info"]["voting_period"]["index"] : meta["level"]["voting_period"]
      Rails.logger.debug "#{chain.name} is currently on Period #{current_period} at Block #{latest_block}"

      # Cycle through voting periods and sync those that are a) missing, b) incomplete, or c) don't have start / end positions
      0.upto(current_period).each do |period|
        pd = Tezos::VotingPeriod.find_by(id: period)

        if pd.nil? || !pd.voting_processed || pd.start_position.nil? || pd.end_position.nil?
          meta           = rpc.get("blocks/#{start_block}/metadata")
          start_block    = meta["voting_period_info"].present? ? meta["voting_period_info"]["voting_period"]["start_position"] + 1 : meta["level"]["level"] - meta["level"]["voting_period_position"]
          constants      = rpc.get("blocks/#{start_block}/context/constants")
          end_block      = start_block + constants["blocks_per_voting_period"]

          Tezos::GovernanceSyncService.new(chain, period, start_block, end_block, latest_block).run
        end

        start_block = end_block + 1
      end
    end
  end
end
