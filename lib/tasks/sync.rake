require "benchmark"
require Rails.root.join("app/services/baking_bad/baker")

task sync: :environment do

  def time(message)
    puts message

    time = Benchmark.realtime do
      yield
    end

    puts "Finished in #{time} seconds"
  end

  def rpc_url(chain, path)
    URI::Generic.build(
      scheme: chain.use_ssl_for_rpc? ? "https" : "http",
      host: chain.rpc_host.presence || "localhost",
      port: chain.rpc_port,
      path: [chain.rpc_path.sub(/\/$/, ''), path].join("/")
    ).to_s
  end

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

  # sync = Tezos::Sync.new(chain)

  # SYNC BAKERS
  time "Syncing bakers" do
    url = rpc_url(chain, "chains/#{chain.internal_name}/blocks/head/context/raw/json/delegates")
    res = Typhoeus.get(url)
    all_bakers = JSON.parse(res.body)
    found_bakers = Tezos::Baker.pluck(:id)
    missing_bakers = all_bakers - found_bakers
    missing_bakers.each do |id|
      Tezos::Baker.create(id: id, chain: chain)
    end
  end

  time "Update baker names from BakingBad" do
    baking_bad_bakers = BakingBad::Baker.list
    if baking_bad_bakers
      local_bakers = chain.bakers.where(name: nil, url: nil).index_by(&:address)
      baking_bad_bakers.each do |baker|
        local_baker = local_bakers[baker.address]
        next unless local_baker
        local_baker.update_columns(name: baker.name, url: baker.site)
      end
    end
  end


  # SYNC CYCLES
  url = rpc_url(chain, "chains/#{chain.internal_name}/blocks/head/metadata")
  res = Typhoeus.get(url)
  data = JSON.parse(res.body)
  current_cycle = data["level"]["cycle"]
  latest_block  = data["level"]["level"]

  time "Syncing cycles" do
    all_cycles = (1..current_cycle)
    found_cycles = Tezos::Cycle.pluck(:id)
    missing_cycles = all_cycles.to_a - found_cycles
    missing_cycles.each do |n|
      puts "Seeding cycle #{n}"
      cycle = Tezos::Cycle.create(id: n, chain: chain)
      cycle.get_constants_from_rpc
    end
  end


  cycle_ids_to_sync = Tezos::Cycle.where.not(all_blocks_synced: true).order(id: :asc).pluck(:id)
  cycle_ids_to_sync.each do |n|
    hydra = Typhoeus::Hydra.new(max_concurrency: 100)
    blocks = {}

    start_height = n * 4096 + 1
    end_height = [start_height + 4096 - 1, latest_block].min
    all_heights = (start_height..end_height).to_a
    found_heights = Tezos::Block.where(cycle_id: n).pluck(:id)
    missing_heights = all_heights - found_heights
    puts "Seeding #{missing_heights.length} blocks for cycle #{n}"

    start_time = Time.now

    missing_heights.each do |height|
      next if height == 1

      url = rpc_url(chain, "chains/#{chain.internal_name}/blocks/#{height}")
      request = Typhoeus::Request.new(url, method: :get)

      request.on_complete do |response|
        if response.success?
          begin
            block_info = JSON.parse(response.body)

            ## Calculate bitmask of endorsed slots for previous block ##################
            if height > 2
              res = Tezos::EndorsementResults.new(bitmask: 0, endorsers: [])

              block_info["operations"].flatten.each do |op|
                endorsements = op["contents"].select { |subop| subop["kind"] == "endorsement" }
                endorsements.each do |endorsement|
                  endorsement["metadata"]["slots"].each do |slot|
                    res.set_true(slot + 1) # slots are 1-indexed in EndorsementResults and 0-indexed in RPC result
                  end
                end
              end
            end
            ############################################################################

            blocks[height.to_s] = {
              id: height,
              id_hash: block_info["hash"],
              cycle_id: n,
              timestamp: Time.parse(block_info["header"]["timestamp"]),
              baker_id: block_info["metadata"]["baker"],
              baker_priority: block_info["header"]["priority"],
              endorsed_slots: res&.bitmask,
            }
          rescue
            puts "ERROR PARSING BLOCK #{height}"
            puts response.body
          end
        end
      end

      hydra.queue(request)
    end

    hydra.run

    missing_heights.each do |height|
      next if height == 1

      url = rpc_url(chain, "chains/#{chain.internal_name}/blocks/#{height}/helpers/endorsing_rights")
      request2 = Typhoeus::Request.new(url, method: :get)

      request2.on_complete do |response|
        if response.success?
          endorsers = []
          data = JSON.parse(response.body)

          data.each do |right|
            right["slots"].each do |slot|
              endorsers[slot] = right["delegate"]
            end
          end

          blocks[height.to_s][:endorsers] = endorsers
        end
      end

      hydra.queue(request2)
    end

    hydra.run

    Tezos::Block.import blocks.values, validate: false




    # GET SNAPSHOT HEIGHT FOR EACH CYCLE #########################################
    time "Getting snapshot height for cycles" do
      cycles = chain.cycles
      cycles_by_number = cycles.index_by(&:number)

      cycles.select { |c| c.needs_snapshot? }.each do |cycle|
        snapshot_cycle = cycles_by_number[cycle.snapshot_cycle_number]
        next unless snapshot_cycle

        url = rpc_url(chain, "chains/#{chain.internal_name}/blocks/#{cycle.start_height}/context/raw/json/cycle/#{cycle.number}/roll_snapshot")
        res = Typhoeus.get(url)
        snapshot_index = JSON.parse(res.body)
        snapshot_height = ((cycle.snapshot_cycle_number) * snapshot_cycle.blocks_per_cycle + 1) + (snapshot_index + 1) * snapshot_cycle.blocks_per_roll_snapshot - 1
        cycle.update_columns(snapshot_id: snapshot_height) if snapshot_height > 1
      end
    end
    ##############################################################################

    # GET TOTAL ROLLS FOR EACH CYCLE #############################################
    time "Getting total rolls for cycles" do
      chain.cycles.where(total_rolls: nil).where.not(snapshot_id: nil).find_each do |cycle|
        url = rpc_url(chain, "chains/#{chain.internal_name}/blocks/#{cycle.snapshot.id_hash}/context/raw/json/rolls/owner/current")
        res = Typhoeus.get(url)
        data = JSON.parse(res.body)
        total_rolls = data.is_a?(Array) ? data.length : nil
        cycle.update_columns(total_rolls: total_rolls)
      end
    end
    ##############################################################################

    ## GET MISSED BAKING RIGHTS FOR BLOCKS WHERE P > 0 ##############################
    # TODO: some blocks (like 748291) seem to be missing right for certain priorities...
    # (that one had a priority of 2 but no rights for priority 1)...
    # does that mean baker at priority 0 also had rights at priority 1 (which is what tzstats says)?
    hydra = Typhoeus::Hydra.new(max_concurrency: 60)
    missed_bakes = []
    intended_bakers = {}

    Tezos::Block.missed.where(intended_baker_id: nil).find_each do |block|
      height = block.id - 1
      url = rpc_url(chain, "chains/#{chain.internal_name}/blocks/#{height}/helpers/baking_rights")
      request = Typhoeus::Request.new(url, method: :get)

      request.on_complete do |response|
        if response.success?
          rights = JSON.parse(response.body)
          rights.each do |r|
            if r["priority"] < block.baker_priority
              missed_bakes << { block_id: block.id, baker_id: r["delegate"], priority: r["priority"] }
            end
          end
          intended_bakers[block.id.to_s] = rights.find { |r| r["priority"] == 0 }["delegate"]
        end
      end

      hydra.queue(request)
    end

    hydra.run

    intended_bakers.each do |height, baker_id|
      Tezos::Baker.find_or_create_by(id: baker_id, chain: chain)
      Tezos::Block.find(height.to_i).update_columns(intended_baker_id: baker_id)
    end
    Tezos::MissedBake.import missed_bakes, validate: false
    #################################################################################

    ## CACHE ENDORSING STATS ####################################################################
    time "Caching endoring stats" do
      Tezos::Cycle.where("cached_endorsing_stats IS NULL OR all_blocks_synced != ?", true).find_each do |cycle|
        cycle.update_columns(cached_endorsing_stats: cycle.endorsing_stats)
      end
    end
    #############################################################################################

    ## CACHE BAKING STATS #######################################################################
    time "Caching baking stats" do
      Tezos::Cycle.where("cached_baking_stats IS NULL OR all_blocks_synced != ?", true).find_each do |cycle|
        cycle.update_columns(cached_baking_stats: cycle.baking_stats)
      end
    end
    #############################################################################################

    ## CACHE CYCLE START & END TIMES ############################################################
    time "Caching blocks count" do
      Tezos::Cycle.where.not(all_blocks_synced: true).find_each do |cycle|
        cycle.update_columns(blocks_count: cycle.blocks.count)
      end
    end
    #############################################################################################

    ## CACHE CYCLE START & END TIMES ############################################################
    time "Caching cycle start & end times" do
      Tezos::Cycle.where("cached_start_time IS NULL OR all_blocks_synced != ?", true).find_each do |cycle|
        cycle.update_columns(cached_start_time: cycle.start_time, cached_end_time: cycle.end_time) if cycle.blocks_count > 0
      end
    end
    #############################################################################################

    ## KEEP TRACK OF CYCLES THAT WE HAVE ALL BLOCKS FOR SO WE CAN SKIP THEM IN NEXT SYNC RUN ####
    Tezos::Cycle.where.not(all_blocks_synced: true).find_each do |cycle|
      if cycle.blocks_count == cycle.blocks_per_cycle ||
          cycle.number == 0 && cycle.blocks.count == cycle.blocks_per_cycle - 1
        cycle.update_columns(all_blocks_synced: true)
      end
    end
    #############################################################################################

    # TODO: Also need reason for misses...could be tricky to keep things fast

    puts "Finished in #{Time.now - start_time} seconds"
  end
end
