module Tezos
  class Event
    class Steal < Tezos::Event
      alias_attribute :baker, :sender
    end
  end
end
