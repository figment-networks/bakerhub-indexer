module Tezos
  class Event
    class DoubleBake < Tezos::Event
      alias_attribute :accuser, :sender
      alias_attribute :offender, :receiver
    end
  end
end
