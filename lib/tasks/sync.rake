require "task_lock"

task sync: :environment do
  $stdout.sync = true
  TaskLock.with_lock!(:sync) do
    puts "Setting up Tezos Chain"
    chain = Tezos::Chain.create_with(
      slug: "mainnet",
      internal_name: "NetXdQprcVkpaWU",
      primary: true,
      rpc_host: SECRETS.rpc_host,
      rpc_port: 443,
      rpc_path: SECRETS.rpc_path,
      use_ssl_for_rpc: true
    ).find_or_create_by(
      name: "Mainnet"
    )

    # SYNC BAKERS
    Tezos::BakerSyncService.new(chain).run

    # SYNC CYCLES
    # TODO: Save current cycle and latest block to Cycle
    data = Tezos::Rpc.new(chain).get("blocks/head/metadata")
    current_cycle = data["level"]["cycle"]
    latest_block  = data["level"]["level"]

    puts "#{chain.name} is currently on Cycle #{current_cycle} at Block #{latest_block}"

    incomplete_local_cycles = Tezos::Cycle.where.not(all_blocks_synced: true).order(id: :asc).pluck(:id)
    missing_local_cycles    = (0..current_cycle).to_a - Tezos::Cycle.pluck(:id)

    incomplete_local_cycles.each { |n| Tezos::CycleSyncService.new(chain, n, latest_block).run }
    missing_local_cycles.each { |n| Tezos::CycleSyncService.new(chain, n, latest_block).run }
  end
end
