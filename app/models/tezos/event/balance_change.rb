module Tezos
  class Event
    class BalanceChange < Tezos::Event
      THRESHOLD = 0.5 / 100.0

      alias_attribute :baker, :sender

      store_accessor :data, :to, :from

      def delta
        to - from
      end

      def from
        super || 0
      end

      def significant?
        percentage_change.abs >= THRESHOLD
      end

      def percentage_change
        to.to_d / from.to_d - 1
      end
    end
  end
end
