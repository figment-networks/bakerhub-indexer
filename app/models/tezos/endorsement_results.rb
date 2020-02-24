module Tezos
  class EndorsementResults
    attr_accessor :bitmask, :endorsers

    def initialize(bitmask: 0, endorsers:)
      @bitmask = bitmask
      @endorsers = endorsers
    end

    def set_false(slot)
      @bitmask &= ~(1 << slot - 1)
    end

    def set_true(slot)
      @bitmask |= (1 << slot - 1)
    end

    def endorsed?(slot)
      @bitmask & (1 << slot - 1) > 0
    end

    def missed?(slot)
      !endorsed?(slot)
    end

    def missed_slots_count(baker_id: nil)
      missed_slots(baker_id: baker_id).length
    end

    def endorsed_slots_count(baker_id: nil)
      endorsed_slots(baker_id: baker_id).length
    end

    def total_slots_count(baker_id: nil)
      total_slots(baker_id: baker_id).length
    end

    def missed_slots(baker_id: nil)
      (1..32).select { |slot| missed?(slot) && (baker_id.nil? || endorsers[slot-1] == baker_id) }
    end

    def endorsed_slots(baker_id: nil)
      (1..32).select { |slot| endorsed?(slot) && (baker_id.nil? || endorsers[slot-1] == baker_id) }
    end

    def total_slots(baker_id: nil)
      (1..32).select { |slot| (baker_id.nil? || endorsers[slot-1] == baker_id) }
    end

    def by_slot
      (1..32).each_with_object({}) do |slot, hash|
        hash[slot] = endorsed?(slot)
      end
    end
  end
end
