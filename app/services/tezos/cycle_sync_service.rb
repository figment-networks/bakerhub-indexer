module Tezos
  class CycleSyncService
    include Tezos::Timer

    attr_reader :chain, :cycle_number

    def initialize(chain, cycle_number)
      @chain = chain
      @cycle_number = cycle_number
    end

    def run
      create_cycle
    end

    def create_cycle
      time "Creating cycle #{cycle_number}" do
        @cycle = Tezos::Cycle.find_or_create_by(id: cycle_number, chain: chain)
        @cycle.get_constants_from_rpc
      end
    end
  end
end
