module Tezos
  class EndorsersSyncService
    attr_accessor :chain, :height

    def initialize(chain, height)
      @chain = chain
      @height = height
    end

    def on_success
      request.on_success do |response|
        if response.success?
          endorsers = []
          data = JSON.parse(response.body)

          data.each do |right|
            right["slots"].each do |slot|
              endorsers[slot] = right["delegate"]
            end
          end

          yield endorsers
        end
      end
    end

    def request
      @request ||= Typhoeus::Request.new(url, method: :get)
    end

    def run
      request.run
    end

    private

    def url
      @url ||= Tezos::Rpc.new(chain).url("blocks/#{height}/helpers/endorsing_rights")
    end
  end
end
