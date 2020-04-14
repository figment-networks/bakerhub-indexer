module Tezos
  class Event
    class MissedEndorsement < Tezos::Event
      alias_attribute :baker, :sender
    end
  end
end
