require 'timeout'
module Ddt
  module OrderService
    module Api
      class ConnectError < ::StandardError; end;
      module Base
        extend ActiveSupport::Concern
        included do
        end
        module ClassMethods
          def mock_for(*method_names)
            method_names.each do |method_name|
              if OrderService::Config.mock
                define_singleton_method "#{method_name}_with_mock".to_sym do |*args|
                  if OrderService::Config.mock
                    # puts "----------#{method_name}-------------"
                    # args.each{|arg| puts arg.to_json }
                    result = OrderService::Api::Mock.const_get(self.name.demodulize).send(*args.unshift(method_name))
                    # puts result.to_json
                    result
                  else
                    self.send("#{method_name}_without_mock")
                  end
                end
                eigenclass = class << self; self; end
                eigenclass.class_eval do
                  alias_method "#{method_name}_without_mock", method_name
                  alias_method method_name, "#{method_name}_with_mock"
                end
              end
            end
          end

          def service_get(url, params={})
            path = "#{url}.#{content_type}?#{params.to_query}"
            response_body = connect(path, {}) do |host|
              URI.parse("#{host}#{path}").read
            end
            OrderService::Api::Result.new(response_body).data
          end

          def service_post(url, params={}, body)
            path = "#{url}.#{content_type}?#{params.to_query}"
            response_body = connect(path, body) do |host|
              uri = URI.parse("#{host}#{path}")
              http = Net::HTTP.new(uri.host,uri.port)
              req = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
              req.body = body.is_a?(String) ? body : body.try(:to_json)
              http.request(req).body
            end
            OrderService::Api::Result.new(response_body).data
          end

          def service_put(url, params={}, body)
            path = "#{url}.#{content_type}?#{params.to_query}"
            response_body = connect(path, body) do |host|
              uri = URI.parse("#{host}#{path}")
              http = Net::HTTP.new(uri.host,uri.port)
              req = Net::HTTP::Put.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
              req.body = body.is_a?(String) ? body : body.try(:to_json)
              http.request(req).body
            end
            OrderService::Api::Result.new(response_body).data
          end

          def service_head(url, params={}, body)
            path = "#{url}.#{content_type}?#{params.to_query}"
            response_body = connect(path, body) do |host|
              uri = URI.parse("#{host}#{path}")
              http = Net::HTTP.new(uri.host,uri.port)
              req = Net::HTTP::Head.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
              req.body = body.is_a?(String) ? body : body.try(:to_json)
              http.request(req).body
            end
            OrderService::Api::Result.new(response_body).data
          end

          def connect(path, request_body)
            puts path
            puts request_body.to_json
            response_body = nil
            retry_with_times do
              servers.each do |host|
                begin
                  response_body = Timeout::timeout(5){ yield(host) }
                  break
                rescue => e
                  Rails.logger.error "order_service api server connect error host: #{host}"
                  next
                end
              end
            end
            response_body ? response_body : raise(Api::ConnectError.new({path: path, request_body: request_body, response_body: response_body}.to_s))
          end

          def retry_with_times(options={})
            tries = (options[:times] || 2)
            begin
              yield
            rescue Api::ConnectError => e
              if (tries -= 1) > 0
                retry
              else
                raise e
              end
            end
          end

          def servers
            OrderService::Config.servers
          end

          def content_type
            OrderService::Config.content_type
          end
        end
      end
    end
  end
end