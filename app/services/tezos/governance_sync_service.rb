module Tezos
  class GovernanceSyncService
    include Tezos::Timer

    attr_reader :chain

    def initialize(chain, voting_period, latest_block)
      @chain = chain
      @period_number = voting_period
      @voting_period = Tezos::VotingPeriod.find_or_create_by(id: voting_period, chain: chain)

      @latest_block = latest_block
      @starting_block = (voting_period * 32768) + 1
      @ending_block = (voting_period + 1) * 32768

      @proposals = []
      @ballots = []
    end

    def run
      return if @voting_period.all_blocks_synced

      get_voting_period_info

    end

    def get_voting_period_info

      time "Starting period number #{@period_number}, blocks #{@starting_block} through #{@ending_block}" do
        url = Tezos::Rpc.new(@chain).url("blocks/#{@starting_block}/votes/current_quorum")
        request = Typhoeus.get(url)
        quorum = request.body

        url = Tezos::Rpc.new(@chain).url("blocks/#{@starting_block}")
        block = JSON.parse(Typhoeus.get(url).body)
        period_type = block["metadata"]["voting_period_kind"]
        starting_time = block["header"]["timestamp"]
        block_hash = block["hash"]

        if @voting_period.voting_power == nil && @period_number > 9
          url = Tezos::Rpc.new(@chain).url("blocks/#{block_hash}/votes/listings")
          voting = JSON.parse(Typhoeus.get(url).body)
          puts voting.inspect
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
                    period_end_block: ending_time,
                    quorum: quorum,
                    voting_power: voting
                  )
      end
    end
  end
end
