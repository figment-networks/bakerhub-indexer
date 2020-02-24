module BakingBad
  class Baker
    include ActiveModel::Model

    attr_accessor :name, :address, :site, :logo, :balance, :stakingBalance,
                  :stakingCapacity, :maxStakingBalance, :freeSpace, :estimatedRoi

    def self.base_url
      "https://api.baking-bad.org"
    end

    def self.list
      r = begin
        RestClient::Request.execute(
          method: :get,
          url: "#{self.base_url}/v1/bakers",
          read_timeout: 2,
          open_timeout: 1,
        )
      rescue RestClient::Exceptions::Timeout
        nil
      end

      if r && r.code == 200
        JSON.load(r.body).map { |e| new(e)  }
      elsif r
        puts "BAKING BAD RESPONSE: error (#{r.status}) #{r.body}" if debug
        nil
      else
        puts "BAKING BAD TIMEOUT"
        nil
      end
    end
  end
end
