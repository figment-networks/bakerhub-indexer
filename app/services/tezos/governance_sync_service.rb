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
      get_proposal_and_ballot_info
      if @voting_period.all_blocks_synced
        perform_end_of_period_calculations
      end
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
            total_voters = voting.count
            total_rolls = voting.sum { |v| v["rolls"] }
            @voting_period.update_columns(voting_power: voting, total_rolls: total_rolls, total_voters: total_voters)
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

      if (@voting_period.blocks_to_sync == []) && (!@voting_period.all_blocks_synced)
        all_blocks = (@starting_block..@ending_block).to_a
        @voting_period.update_columns(blocks_to_sync: all_blocks)
      end

      time "Getting proposal and voting info for period #{@period_number}" do
        @voting_period.blocks_to_sync.each do |height|

          if height > @latest_block then break end

          url = Tezos::Rpc.new(@chain).url("blocks/#{height}")
          request = Typhoeus::Request.new(url, method: :get)

          request.on_complete do |response|
            if response.success?
              block_info = JSON.parse(response.body)
              process_voting_for_block(block_info)
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
      puts "There were #{@proposals} proposals and #{@ballots} ballots synced for this voting period."

      # If there are still unsynced blocks, run again
      if @voting_period.blocks_to_sync == []
        @voting_period.update_columns(all_blocks_synced: true)
      elsif @ending_block <= @latest_block
        puts "#{@voting_period.blocks_to_sync.count} blocks missed, trying again."
        get_proposal_and_ballot_info
      end
    end

    def process_voting_for_block(block_info)
      operations = block_info["operations"]
      operations.each do |o|
        # Block has no operations
        next if o.empty?

        operation = o[0]
        contents = operation["contents"][0]
        kind = contents["kind"]

        # Operation is something other than a proposal or ballot
        next if ((kind != "proposals") && (kind != "ballot"))

        hash_id = operation["hash"]
        block_level = block_info["header"]["level"]
        baker_id = contents["source"]
        vote = contents["ballot"]
        rolls = @voting_period.voting_power.select { |vote| vote["pkh"] == baker_id }
        rolls = rolls[0]["rolls"].to_i
        submitted_time = block_info["header"]["timestamp"]
        baker = Tezos::Baker.find_by(id: baker_id)

        # During prop period, each baker can vote for up to 20 props
        # each prop ID is an element in an array
        # During testing vote and promotion vote, only one vote per baker
        # only one prop ID provided as a string
        proposal_list = []
        if kind == "ballot"
          proposal_list << contents["proposal"]
        else
          proposal_list = contents["proposals"]
        end

        proposal_list.each do |a|
          proposal = Tezos::Proposal.find_or_create_by(id: a) do |p|
            p.chain = @chain
            p.submitted_time = submitted_time
            p.submitted_block = block_level
            p.start_period = @voting_period.id
            puts "Created proposal #{a}"
            @proposals += 1
          end

          ballot = Tezos::Ballot.find_or_create_by(id: hash_id) do |b|
            b.chain = @chain
            b.voting_period = @voting_period
            b.proposal = proposal
            b.baker = baker
            b.vote = vote
            b.rolls = rolls
            b.submitted_block = block_level
            b.created_at = submitted_time
            puts "Created ballot for proposal #{a} for #{rolls} rolls"
            @ballots += 1
          end
        end
      end
    end

    def perform_end_of_period_calculations
      puts "Calculating end of voting period results"
      if @voting_period.period_type == "testing_vote"
        proposal = Tezos::Proposal.find_by(id: @voting_period.ballots.first.proposal_id)
        proposal_promoted = @voting_period.quorum_reached && @voting_period.supermajority_reached?
        proposal.update_columns(passed_eval_period: proposal_promoted)
      elsif @voting_period.period_type == "promotion_vote"
        proposal = Tezos::Proposal.find_by(id: @voting_period.ballots.first.proposal_id)
        proposal_promoted = @voting_period.quorum_reached && @voting_period.supermajority_reached?
        proposal.update_columns(is_promoted: proposal_promoted)
      elsif @voting_period.period_type == "proposal"
        max_votes = [0,""]
        props = Tezos::Proposal.where(start_period: @voting_period.id)
        props.each do  |p|
          votes = p.ballots.where(voting_period_id: @voting_period.id).sum { |b| b.rolls }
          if votes > max_votes[0]
            max_votes = [votes, p.id]
          elsif votes == max_votes[0]
            max_votes << p.id
          end
        end

        # If there is a tie, no prop is promoted
        if max_votes.length == 2
          proposal = Tezos::Proposal.find_by(id: max_votes[1])
          proposal.update_columns(passed_prop_period: true)
        end
      end
      @voting_period.update_columns(voting_processed: true)
    end


    private

    def hydra
      @hydra ||= Typhoeus::Hydra.new(max_concurrency: 100)
    end

  end
end
