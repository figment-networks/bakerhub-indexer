module Tezos
  class Event
    class DoubleEndorsement < Tezos::Event
      alias_attribute :accuser, :sender
      alias_attribute :offender, :receiver
    end
  end
end
