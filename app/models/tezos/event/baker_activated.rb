module Tezos
  module Event
    class BakerActivated < Tezos::Event
      alias_attribute :baker, :sender
    end
  end
end
