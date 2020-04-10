module Tezos
  class Rpc
    attr_reader :chain

    def initialize(chain = Tezos::Chain.primary)
      @chain = chain
    end

    def self.get(path, query = nil)
      new.get(path, query)
    end

    def url(path, query = nil)
      URI::Generic.build(
        scheme: chain.use_ssl_for_rpc? ? "https" : "http",
        host:   chain.rpc_host.presence || "localhost",
        port:   chain.rpc_port,
        path:   [chain.rpc_path.sub(/\/$/, ''), "chains/#{chain.internal_name}", path].join("/"),
        query:  query
      ).to_s
    end

    def get(path, query = nil)
      request = Typhoeus::Request.new(url(path, query), timeout: 45)
      chunks = []
      request.on_body do |chunk|
        chunks << chunk
      end
      request.run
      JSON.parse(chunks.join)
    end
  end
end
