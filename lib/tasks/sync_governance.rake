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
      # Get current period and start block from RPC; calculate end_block
      data = Tezos::Rpc.new(chain).get("blocks/head/metadata")
      latest_block   = data["level_info"]["level"]
      current_period = data["voting_period_info"]["voting_period"]["index"]
      start_block    = data["voting_period_info"]["voting_period"]["start_position"]
      end_block      = start_block + data["voting_period_info"]["position"] + data["voting_period_info"]["remaining"]
      Rails.logger.debug "#{chain.name} is currently on Period #{current_period} at Block #{latest_block}"

      current_period.downto(0).each do |period|
        # Find record in db
        if pd = Tezos::VotingPeriod.find(period)
          if pd.nil? || !pd.voting_processed || pd.start_position.nil? || pd.end_position.nil?
            Tezos::GovernanceSyncService.new(chain, period, start_block, end_block, latest_block).run
          end
        end

        # Get previous period start_block from RPC. we know current period start_block - 1 equals previous period end block.
        end_block = start_block - 1
        # TODO: look up previous period in database and track whether it's been corrected. skip if it has.
        data = Tezos::Rpc.new(chain).get("blocks/#{end_block}/metadata")
        start_block = data["voting_period_info"]["voting_period"]["start_position"]
      end
    end
  end
end
