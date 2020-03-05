module Tezos
  module Rpc
    def rpc_url(chain, path)
      URI::Generic.build(
        scheme: chain.use_ssl_for_rpc? ? "https" : "http",
        host:   chain.rpc_host.presence || "localhost",
        port:   chain.rpc_port,
        path:   [chain.rpc_path.sub(/\/$/, ''), "chains/#{chain.internal_name}", path].join("/")
      ).to_s
    end
  end
end
