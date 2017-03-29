module Ddt
  class Printer
    module Api
      def self.send_post(url, params)
        config = Ddt::Printer.load_print_manager_config
        server = config["server"]
        api_key = config["api_key"]
        access_id = config["access_id"]
        uri = URI.parse("#{server}#{url}.json")
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = 10
        http.read_timeout = 10
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(params)
        request = ApiAuth.sign!(request, access_id, api_key)
        # puts ApiAuth.authentic?(request, api_key)
        response = http.request(request)
        Rails.logger.info " response body: "
        Rails.logger.info response.body
        begin
          result = JSON.parse(response.body)
          if result.is_a? Array
            result.map(&:symbolize_keys)
          else
            result.symbolize_keys
          end
        rescue JSON::ParserError => e
          Rails.logger.error "response body error #{response.body}"
          raise e
        end
      end

      def self.send_get(url, params)
        config = Ddt::Printer.load_print_manager_config
        server = config["server"]
        api_key = config["api_key"]
        access_id = config["access_id"]
        uri = URI.parse("#{server}#{url}.json?#{params.to_query}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = 10
        http.read_timeout = 10
        request = Net::HTTP::Get.new(uri.request_uri, initheader = {'Content-Type' =>'text/plain'})
        request = ApiAuth.sign!(request, access_id, api_key)
        # puts ApiAuth.authentic?(request, api_key)
        response = http.request(request)
        result = JSON.parse(response.body)
        if result.is_a? Array
          result.map(&:symbolize_keys)
        else
          result.symbolize_keys
        end
      end
    end
  end
end