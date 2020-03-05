require "benchmark"

module Tezos
  module Timer
    def time(message)
      puts message

      time = Benchmark.realtime do
        yield
      end

      puts "Finished in #{time} seconds"
    end
  end
end
