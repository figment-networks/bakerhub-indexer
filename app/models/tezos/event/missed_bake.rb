module Tezos
  class Event
    class MissedBake < Tezos::Event
      alias_attribute :baker, :sender
    end
  end
end
