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
      res = Typhoeus.get(url(path, query), timeout: 30)
      JSON.parse(res.body)
    end
  end
end
