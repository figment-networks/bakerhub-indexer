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
      # SYNC PROPOSALS
      data = Tezos::Rpc.new(chain).get("blocks/head/metadata")
      current_period = data["voting_period_info"]["voting_period"]["index"]
      latest_block  = data["level_info"]["level"]

      Rails.logger.debug "#{chain.name} is currently on Period #{current_period} at Block #{latest_block}"

      incomplete_local_periods = chain.voting_periods.where.not(voting_processed: true).order(id: :asc).pluck(:id)
      missing_local_periods    = (0..current_period).to_a - chain.voting_periods.pluck(:id)

      incomplete_local_periods.each { |p| Tezos::GovernanceSyncService.new(chain, p, latest_block).run }
      missing_local_periods.each { |p| Tezos::GovernanceSyncService.new(chain, p, latest_block).run }
    end
  end
end
