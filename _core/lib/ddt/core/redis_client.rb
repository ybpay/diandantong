require 'rqrcode_png'
module Ddt
  module RedisClient
    def self.ins
      return @client if @client.present?
      options = Ddt::RedisClientConfig.to_hash
      @client = Redis.new(options)
    end
  end
end