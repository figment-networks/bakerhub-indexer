task sync: :environment do
  puts "Setting up Tezos Chain"
  chain = Tezos::Chain.create_with(
    slug: "mainnet",
    internal_name: "NetXdQprcVkpaWU",
    primary: true,
    rpc_host: Rails.application.credentials.rpc_host,
    rpc_port: 443,
    rpc_path: Rails.application.credentials.rpc_path,
  ).find_or_create_by(
    name: "Mainnet",
    use_ssl_for_rpc: true
  )

  # SYNC BAKERS
  Tezos::BakerSyncService.new(chain).run

  # SYNC CYCLES
  # TODO: Save current cycle and latest block to Cycle
  url = Tezos::Rpc.new(chain).url("blocks/head/metadata")
  res = Typhoeus.get(url)
  data = JSON.parse(res.body)
  current_cycle = data["level"]["cycle"]
  latest_block  = data["level"]["level"]

  puts "#{chain.name} is currently on Cycle #{current_cycle} at Block #{latest_block}"

  incomplete_local_cycles = Tezos::Cycle.where.not(all_blocks_synced: true).order(id: :asc).pluck(:id)
  missing_local_cycles    = (0..current_cycle).to_a - Tezos::Cycle.pluck(:id)

  incomplete_local_cycles.each { |n| Tezos::CycleSyncService.new(chain, n, latest_block).run }
  missing_local_cycles.each { |n| Tezos::CycleSyncService.new(chain, n, latest_block).run }

  # cycle_ids_to_sync = Tezos::Cycle.where.not(all_blocks_synced: true).order(id: :asc).pluck(:id)
  # cycle_ids_to_sync.each do |n|
  #
  #   ## GET MISSED BAKING RIGHTS FOR BLOCKS WHERE P > 0 ##############################
  #   # TODO: some blocks (like 748291) seem to be missing right for certain priorities...
  #   # (that one had a priority of 2 but no rights for priority 1)...
  #   # does that mean baker at priority 0 also had rights at priority 1 (which is what tzstats says)?
  #   hydra = Typhoeus::Hydra.new(max_concurrency: 60)
  #   missed_bakes = []
  #   intended_bakers = {}
  #
  #   Tezos::Block.missed.where(intended_baker_id: nil).find_each do |block|
  #     height = block.id - 1
  #     url = Tezos::Rpc.new(chain).url("blocks/#{height}/helpers/baking_rights")
  #     request = Typhoeus::Request.new(url, method: :get)
  #
  #     request.on_complete do |response|
  #       if response.success?
  #         rights = JSON.parse(response.body)
  #         rights.each do |r|
  #           if r["priority"] < block.baker_priority
  #             missed_bakes << { block_id: block.id, baker_id: r["delegate"], priority: r["priority"] }
  #           end
  #         end
  #         intended_bakers[block.id.to_s] = rights.find { |r| r["priority"] == 0 }["delegate"]
  #       end
  #     end
  #
  #     hydra.queue(request)
  #   end
  #
  #   hydra.run
  #
  #   intended_bakers.each do |height, baker_id|
  #     Tezos::Baker.find_or_create_by(id: baker_id, chain: chain)
  #     Tezos::Block.find(height.to_i).update_columns(intended_baker_id: baker_id)
  #   end
  #   Tezos::MissedBake.import missed_bakes, validate: false
  #   #################################################################################

  #   # TODO: Also need reason for misses...could be tricky to keep things fast
  #
  #   puts "Finished in #{Time.now - start_time} seconds"
  # end
end
