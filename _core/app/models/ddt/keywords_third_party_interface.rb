# encoding:utf-8
require 'net/http'
require "uri"
module Ddt
  class KeywordsThirdPartyInterface < ActiveRecord::Base
    include ActsAsType
    belongs_to :wechat_account, class_name: "Ddt::WechatAccount"

    validates_presence_of :keywords, :api, :match_type, :token
    validates :api, uri: true

    acts_as_type :match_type, [:match_keyword, :match_head, :match_all], %W[关键词包含匹配 前缀包含匹配 精确匹配]

    scope :opened, ->{ where(opened: true) }

    def siblings
      self.wechat_account.keywords_third_party_interfaces
    end

    def keywords_array
      self.keywords.split(' ')
    end

    def keywords_match?(content)
      if self.is_match_keyword?
        self.keywords_array.any?{ |keyword| content.include?(keyword) }
      elsif self.is_match_head?
        self.keywords_array.any?{ |keyword| content.start_with?(keyword) }
      elsif self.is_match_all?
        self.keywords_array.any?{ |keyword| content == keyword }
      end
    end

    def validate_api?
      echostr = (0...20).map{ ('a'..'z').to_a[rand(26)] }.join
      begin
        if self.is_input_text?
          uri = self.api_uri(echostr: echostr)
          response = Net::HTTP.get(uri)
        elsif self.is_input_standard?
          uri_params = { timestamp: Time.now.to_i, nonce: Random.rand(100000), echostr: echostr}
          uri_params[:signature] = Ddt::MessageReception.calculate_message_signature(self.token, uri_params[:timestamp], uri_params[:nonce])
          uri = self.api_uri(uri_params)
          response = Net::HTTP.get(uri)
        end
      rescue Exception => e
        Rails.logger.error "validation failed, reason: "
        Rails.logger.error e.message
      end
      response.present? && (response == echostr)
    end

    def send_message(request, params)
      begin
        new_signature = Ddt::MessageReception.calculate_message_signature(self.token, params[:timestamp], params[:nonce])
        request.body.rewind
        uri_params = { timestamp: params[:timestamp], nonce: params[:nonce], signature: new_signature }
        uri = self.api_uri(uri_params)
        response = Net::HTTP.start(uri.host, uri.port, :read_timeout => 10) do |http|
          new_request = Net::HTTP::Post.new(uri.request_uri)
          new_request.body            = request.body.read
          new_request["Content-Type"] = "application/xml"
          new_request["Accept"]       = "*/*"
          http.request(new_request)
        end
      rescue => e
      end
      if response.present? && response.body.present?
        response.body
      end
    end

    def api_uri(params={})
      uri = URI.parse(self.api)
      if params.present?
        new_query_params = URI.decode_www_form(uri.query || []) + params.to_a
        uri.query = URI.encode_www_form(new_query_params)
      end
      uri
    end

  end
end