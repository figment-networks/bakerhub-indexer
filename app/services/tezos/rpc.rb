module Tezos
  class Rpc
    attr_reader :chain

    def initialize(chain = Tezos::Chain.primary)
      @chain = chain
    end

    def self.get(path)
      new.get(path)
    end

    def url(path)
      URI::Generic.build(
        scheme: chain.use_ssl_for_rpc? ? "https" : "http",
        host:   chain.rpc_host.presence || "localhost",
        port:   chain.rpc_port,
        path:   [chain.rpc_path.sub(/\/$/, ''), "chains/#{chain.internal_name}", path].join("/")
      ).to_s
    end

    def get(path)
      res = Typhoeus.get(url(path))
      JSON.parse(res.body)
    end
  end
end
