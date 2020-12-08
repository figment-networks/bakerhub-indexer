module Tezos
  class Event
    class BakerDeactivated < Tezos::Event
      alias_attribute :baker, :sender
    end
  end
end
