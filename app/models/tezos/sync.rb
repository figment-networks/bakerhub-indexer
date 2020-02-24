module Tezos
  class Sync
    def initialize(chain)
      @chain = chain
    end

    def get_block_by_hash( id_hash, subpath: nil )
      rpc_get( 'chains', @chain.internal_name,
               'blocks', id_hash, subpath, strict: true )
    end

    def baking_rights( cycle_number, id_hash=head, baker_address=nil )
      params = { cycle: cycle_number, max_priority: 5 }
      params[:delegate] = baker_address if baker_address
      rpc_get( 'chains', @chain.internal_name,
               'blocks', id_hash,
               'helpers/baking_rights',
               params: params, strict: true )
    end

    def endorsing_rights( cycle_number, id_hash=head, baker_address=nil )
      params = { cycle: cycle_number }
      params[:delegate] = baker_address if baker_address
      rpc_get( 'chains', @chain.internal_name,
               'blocks', id_hash,
               'helpers/endorsing_rights',
               params: params, strict: true )
    end

    def get_block_by_height( height, head: nil, subpath: nil )
      tries = 3
      begin
        head ||= get_block_by_hash( head || 'head', subpath: 'header' )
        current_head_height = head['level']
        current_head_hash = head['hash']
      rescue
        if tries > 0
          tries -= 1
          sleep 0.25
          retry
        else
          raise "Could not get preliminary head to calculate block delta #{height} #{$!.message}"
        end
      end

      diff = current_head_height - height.to_i
      return nil if diff < 0

      tries = 3
      begin
        r = rpc_get( 'chains', @chain.internal_name,
                     'blocks', "#{current_head_hash}~#{diff}", subpath,
                     strict: true )
        raise if r.nil?
      rescue
        if tries > 0
          sleep 0.25
          tries -= 1
          retry
        else
          raise "Invalid block retrieved after 3 tries for height #{height} (from head #{head.inspect}, diff #{diff}"
        end
      end
      r
    end

    def get_constants(hash)
      rpc_get('chains', @chain.internal_name, 'blocks', hash, 'context/constants')
    end

    def registered_bakers( id_hash='head' )
      rpc_get( 'chains', @chain.internal_name,
               'blocks', id_hash,
               'context/raw/json/delegates' )
    end

    private

    def rpc_get( *path, params: nil, debug: false, strict: false )
      path = path.compact.join('/') if path.is_a?(Array)

      body = begin
        start_time = Time.now.utc.to_f
        puts "#{@chain.network_name} RPC GET: #{path}" if debug

        begin
          res = StringIO.new
          RestClient::Request.execute(
            method: :get,
            url: "http://#{@chain.rpc_host}:8732/#{path}",
            read_timeout: 30 * 2,
            open_timeout: 30,
            headers: { params: params },
            block_response: proc { |response| res << response.read_body }
          )
          res.rewind
        rescue => e
          nil
          # r = e.response
        end
        end_time = Time.now.utc.to_f
        puts "#{@chain.network_name} RPC #{path} took #{end_time - start_time} seconds" if debug
        res.read
      end

      begin
        JSON.load( body )
      rescue
        if strict
          puts "Invalid RPC response: #{body}\n\nPATH: #{path}\nPARAMS: #{params}\n\n"
          raise $!
        else
          body
        end
      end
    end
  end
end
