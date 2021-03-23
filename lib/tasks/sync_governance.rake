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


    # TODO: GET START AND END USING THIS DATA
    # data = Tezos::Rpc.new(chain).get("blocks/head/metadata")
    # current_period = data["voting_period_info"]["voting_period"]["index"]
                  # OR data["level"]["voting_period"]
    # start_block    = data["voting_period"]["start_positon"] + 1
                  # OR data["level"]["level"] - data["level"]["voting_period_position"]

    # constants = Tezos::Rpc.new(chain).get("blocks/#{start_block}/context/constants")
    # blocks_per_voting_period = constants["blocks_per_voting_period"]
    # end_block = start_block + blocks_per_voting_period


    chains.each do |chain|
      # Get current period and start block from RPC; calculate end_block
      # TODO: Handle protocols before Edo
      data = Tezos::Rpc.new(chain).get("blocks/head/metadata")
      latest_block   = data["level_info"]["level"]
      current_period = data["voting_period_info"]["voting_period"]["index"]
      start_block    = data["voting_period_info"]["voting_period"]["start_position"]
      end_block      = start_block + data["voting_period_info"]["position"] + data["voting_period_info"]["remaining"]
      Rails.logger.debug "#{chain.name} is currently on Period #{current_period} at Block #{latest_block}"

      current_period.downto(0).each do |period|
        # Find record in db
        pd = Tezos::VotingPeriod.find_by(id: period)
        if pd.nil? || !pd.voting_processed || pd.start_position.nil? || pd.end_position.nil?
          Tezos::GovernanceSyncService.new(chain, period, start_block, end_block, latest_block).run
        end

        # Get previous period start_block from RPC. we know current period start_block - 1 equals previous period end block.
        end_block = start_block - 1
        puts "Look up data for period #{period} with end block #{end_block}"
        data = Tezos::Rpc.new(chain).get("blocks/#{end_block}/metadata")
        start_block = data["voting_period_info"]["voting_period"]["start_position"]
      end
    end
  end
end
