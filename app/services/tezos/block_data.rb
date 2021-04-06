module Tezos
  class BlockData
    attr_accessor :metadata, :header, :hash, :timestamp, :chain

    def initialize(data, chain)
      self.chain = chain
      self.metadata = data["metadata"]
      self.header = data["header"]
      self.hash = data["hash"]
      self.timestamp = data["header"]["timestamp"]
    end

    def self.retrieve(chain: Chain.primary, block_id: "head")
      data = Rpc.new(chain).get("blocks/#{block_id}")
      new(data, chain)
    end

    def baker
      metadata["baker"]
    end

    def priority
      header["priority"]
    end

    def protocol
      metadata["protocol"]
    end

    def next_protocol
      metadata["next_protocol"]
    end

    def level
      if metadata["level_info"]
        metadata["level_info"]["level"]
      else
        metadata["level"]["level"]
      end
    end

    def cycle
      if metadata["level_info"]
        metadata["level_info"]["cycle"]
      else
        metadata["level"]["cycle"]
      end
    end

    def voting_period
      if metadata["voting_period_info"]
        metadata["voting_period_info"]["voting_period"]["index"]
      else
        metadata["level"]["voting_period"]
      end
    end

    def voting_period_position
      if metadata["voting_period_info"]
        metadata["voting_period_info"]["position"]
      else
        metadata["level"]["voting_period_position"]
      end
    end

    def voting_period_start_block
      if metadata["voting_period_info"]
        metadata["voting_period_info"]["voting_period"]["start_position"] + 1
      else
        level - voting_period_position
      end
    end

    def voting_period_end_block
      voting_period_start_block + blocks_per_voting_period - 1
    end

    def blocks_per_voting_period
      constants["blocks_per_voting_period"]
    end

    def voting_period_kind
      if metadata["voting_period_info"]
        metadata["voting_period_info"]["voting_period"]["kind"]
      else
        metadata["voting_period_kind"]
      end
    end

    private

    def constants
      @constants ||= Tezos::Rpc.new(chain).get("blocks/#{voting_period_start_block}/context/constants")
    end
  end
end
