#encoding: utf-8
module Ddt
  class CloudServer

    class ControllerUrls

      def initialize(*args)
        if args.length == 2
          @shop_id = args[0]
          @branch_id = args[1]
        elsif args.length == 1
          @shop_id = args[0].shop_id
          @branch_id = args[0].branch_id
        else
          msg = <<-ERROR_MESSAGE
          'initialize clouse server url object error, constructor arguments:'
          1. a list, have shop_id and branch_id in order
          2. a object, contains shop_id and branch_id
          ERROR_MESSAGE
          raise msg
        end
      end

      def base
        "http://#{Ddt::CloudServerConfig.host}:#{Ddt::CloudServerConfig.port}"
      end

      def sync
        "#{base}/webpos/api/shops/#{@shop_id}/branches/#{@branch_id}/sync"
      end

      def setup
        "#{base}/admin/api/setup"
      end
    end

    #
    # params
    #   shop_id  (require)
    #   branch_id (require)
    #   id (optional)
    #
    def self.post(ctrl, action, path_params: {}, query_params: {}, body: nil)
      begin
        shop_id = path_params[:shop_id] || query_params[:shop_id]
        branch_id = path_params[:branch_id] || query_params[:branch_id]

        url = "#{ControllerUrls.new(shop_id, branch_id).send(ctrl)}/#{action}"
        token = Ddt::CsBranchBinding.where(branch_id: branch_id).first.try(:token)

        unless token.present?
          raise "post to cs server error, cannot find token for branch #{branch_id}"
        end

        uri = URI.parse(url)
        response = Net::HTTP.start(uri.host, uri.port, :open_timeout => 3, :read_timeout => 10) do |http|
          post = Net::HTTP::Post.new(uri.request_uri, initheader = {'api_key' => token})
          if body.present?
            post.body = body
          else
            post.body = query_params.map{|k,v| "#{k}=#{URI.encode(v.try(:to_s))}"}.join('&')
          end
          Rails.logger.notify_cloud_server.info "post #{url}, body: #{post.body}"
          http.request(post)
        end

        # expect:
        # {
        #   status: 0,
        #   message: "ok",
        #   data: "success" | null
        # }
        result = JSON.parse(response.body)
        unless result['status'] == 0
          message = "failed to post #{url}, error-response=#{response.body}"
          Rails.logger.notify_cloud_server.error message
          raise message
        end
      rescue => e
        message = "failed post #{url}, error-response=#{response.try(:body)}, exception=#{e}"
        Rails.logger.notify_cloud_server.error message
        raise message
      end
    end

  end
end