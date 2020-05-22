require "task_lock"

task sync_governance: :environment do
  $stdout.sync = true
  TaskLock.with_lock!(:sync) do
    puts "Setting Tezos Chain"
    chain = Tezos::Chain.first
    unless chain
      puts "No chain synced, run sync.rake before sync_governance.rake"
      next
    end

    # SYNC PROPOSALS
    data = Tezos::Rpc.new(chain).get("blocks/head/metadata")
    current_period = data["level"]["voting_period"]
    latest_block  = data["level"]["level"]

    puts "#{chain.name} is currently on Period #{current_period} at Block #{latest_block}"

    incomplete_local_periods = Tezos::VotingPeriod.where.not(voting_processed: true).order(id: :asc).pluck(:id)
    missing_local_periods    = (0..current_period).to_a - Tezos::VotingPeriod.pluck(:id)

    incomplete_local_periods.each { |p| Tezos::GovernanceSyncService.new(chain, p, latest_block).run }
    missing_local_periods.each { |p| Tezos::GovernanceSyncService.new(chain, p, latest_block).run }
  end
end
