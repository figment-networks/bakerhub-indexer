module Tezos
  class GovernanceSyncService
    include Tezos::Timer

    def initialize(chain, voting_period, latest_block)
      @chain = chain
      @period_number = voting_period
      @voting_period = Tezos::VotingPeriod.find_or_create_by(id: voting_period, chain: chain)

      @latest_block = latest_block
      @starting_block = (voting_period * 32768) + 1
      @ending_block = (voting_period + 1) * 32768

      @proposals = 0
      @ballots = 0
    end

    def run
      get_voting_period_info

      # TESTING - SKIP 1st 10 periods b/c no proposals present
      if @voting_period.id > 9
        get_proposal_and_ballot_info
      end
      perform_end_of_period_calculations
    end

    def get_voting_period_info
      time "Getting info for period #{@period_number}, blocks #{@starting_block} through #{@ending_block}" do
        url = Tezos::Rpc.new(@chain).url("blocks/#{@starting_block}/votes/current_quorum")
        request = Typhoeus.get(url)
        quorum = request.body

        url = Tezos::Rpc.new(@chain).url("blocks/#{@starting_block}")
        block = JSON.parse(Typhoeus.get(url).body)
        period_type = block["metadata"]["voting_period_kind"]
        starting_time = block["header"]["timestamp"]
        block_hash = block["hash"]

        # Testing period has no proposal submission or voting, can skip block sync
        skip_block_sync = period_type == 'testing' ? true : false

        if @voting_period.voting_power == nil
          url = Tezos::Rpc.new(@chain).url("blocks/#{block_hash}/votes/listings")
          response = Typhoeus.get(url)
          # no voting data before period 10,
          # shouldn't happen after that
          # but no way to separate other causes of 404 response
          if response.response_code == 404
            puts "Error retrieving voting info"
          else
            voting = JSON.parse(response.body)
            @voting_period.update_columns(voting_power: voting)
          end
        end

        if @ending_block <= @latest_block
          url = Tezos::Rpc.new(@chain).url("blocks/#{@ending_block}")
          block = JSON.parse(Typhoeus.get(url).body)
          ending_time = block["header"]["timestamp"]
        end

        @voting_period.update_columns(
                    chain_id: @chain.id,
                    period_type: period_type,
                    period_start_block: @starting_block,
                    period_start_time: starting_time,
                    period_end_block: @ending_block,
                    period_end_time: ending_time,
                    quorum: quorum,
                    all_blocks_synced: skip_block_sync
                  )
      end
    end

    def get_proposal_and_ballot_info
      if @voting_period.period_type == "testing"
        puts "Testing period -- no proposals or voting info"
        return
      end

      if @voting_period.blocks_to_sync == []
        ##TESTING
        skip = @starting_block + 10000
        all_blocks = (skip..@ending_block).to_a
        @voting_period.update_columns(blocks_to_sync: all_blocks)
      end

      time "Getting proposal and voting info for period #{@period_number}" do
        @voting_period.blocks_to_sync.each do |height|
          url = Tezos::Rpc.new(@chain).url("blocks/#{height}")
          request = Typhoeus::Request.new(url, method: :get)

          request.on_complete do |response|
            if response.success?
              block_info = JSON.parse(response.body)
              puts "Processing height #{height}"
              @voting_period.period_type == "proposal" ? process_proposal_period_voting(block_info) : process_voting_period_voting(block_info)
              blocks = @voting_period.blocks_to_sync
              blocks.delete(height)
              @voting_period.update_columns(blocks_to_sync: blocks)
            else
              puts "HTTP request failed for height #{height}: " + response.code.to_s
            end
          end
          hydra.queue(request)
        end
        hydra.run
      end
      puts "There were #{@proposals} proposals and #{@ballots} for this voting period."
    end

    def process_proposal_period_voting(block_info)
      operations = block_info["operations"]
      operations.each do |o|
        next if o.empty?

        operation = o[0]
        contents = operation["contents"][0]
        next if contents["kind"] != "proposals"

        hash_id = operation["hash"]
        block_level = block_info["header"]["level"]
        baker_id = contents["source"]
        proposal_id = contents["proposals"][0]
        rolls = @voting_period.voting_power.select { |vote| vote["pkh"] == baker_id }
        rolls = rolls[0]["rolls"].to_i
        submitted_time = block_info["header"]["timestamp"]
        baker = Tezos::Baker.where(id: baker_id).first

        proposal = Tezos::Proposal.find_or_create_by(id: proposal_id) do |p|
          p.chain = @chain
          p.submitted_time = submitted_time
          p.submitted_block = block_level
          p.start_period = @voting_period
          puts "Created proposal #{proposal_id}"
          @proposals += 1
        end

        ballot = Tezos::Ballot.find_or_create_by(id: hash_id) do |b|
          b.chain = @chain
          b.voting_period = @voting_period
          b.proposal = proposal
          b.baker = baker
          b.rolls = rolls
          b.submitted_block = block_level
          b.created_at = submitted_time
          puts "Created ballot for proposal #{proposal_id} for #{rolls} rolls"
          @ballots += 1
        end
        puts ballot.inspect
      end
    end

    def process_voting_period_voting(block_info)

    end

    def perform_end_of_period_calculations
      puts "Calculating end of voting period results"
    end


    private

    def hydra
      @hydra ||= Typhoeus::Hydra.new(max_concurrency: 100)
    end

  end
end
