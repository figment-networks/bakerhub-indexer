module Tezos
  class CycleSyncService
    include Tezos::Timer

    attr_reader :chain

    def initialize(chain)
      @chain = chain
    end

    def run(cycle_number)
      puts "Syncing cycle #{cycle_number}"
    end
  end
end
