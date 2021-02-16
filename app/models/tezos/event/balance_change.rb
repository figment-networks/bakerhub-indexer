module Tezos
  class Event
    class BalanceChange < Tezos::Event
      alias_attribute :baker, :sender
      store_accessor :data, :to, :from

      def percent_change
        to.to_d / from.to_d - 1
      end
    end
  end
end
