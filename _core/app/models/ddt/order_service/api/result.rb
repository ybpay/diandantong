module Ddt
  module OrderService
    module Api
      class ResultError < ::StandardError; end;
      class DecodeError < ::StandardError; end;
      class Result
        attr_accessor :content, :body

        def initialize(body)
          @body = body
          puts body
          @content = unpack(body).deep_underscore_keys
          raise Api::ResultError.new(message) unless is_status_ok?
        end

        def is_status_ok?
          content[:status] == 200
        end

        def message
          content[:message]
        end

        def data
          # "totalPages": 18,
          # "totalElements": 342,
          # "size": 20,
          # "number": 0,
          # "numberOfElements": 20,
          # "sort": null,
          # "last": false
          # attr_accessor :current_page, :per_page, :is_first_page, :is_last_page, :total_count, :total_pages, :sort, :count, :content
          if content[:number].present?
            {
              current_page:  content[:number],
              per_page:      content[:size],
              is_first_page: content[:number] == 0,
              is_last_page:  content[:last],
              total_pages:   content[:total_pages],
              total_count:   content[:total_elements],
              sort:          content[:sort],
              count:         content[:number_of_elements],
              content:       content[:data],
            }
          else
            content[:data]
          end
        end

        private
        def unpack(body)
          # json msgpack
          # require 'msgpack'
          # msg = [1,2,3].to_msgpack  #=> "\x93\x01\x02\x03"
          # MessagePack.unpack(msg)   #=> [1,2,3]
          case OrderService::Config.content_type
          when 'json'
            ActiveSupport::JSON.decode(body).symbolize_keys
          when 'msgpack'
            MessagePack.unpack(body).symbolize_keys
          end
        rescue => e
          raise Api::DecodeError.new(e.message)
        end
      end
    end
  end
end