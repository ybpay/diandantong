#encoding: utf-8
module Ddt
  module Common
    class MessagesController < Ddt::BaseController

      protect_from_forgery :except => :create
      before_action :set_current_shop, only: [:validate]
      # around_filter :global_request_logging

      def create
        if message_for_authorized_wechat_account?
          if is_weixin_test?
            #全网发布前 微信发来的测试消息
            handle_weixin_test
            return
          else
            @wechat_account = Ddt::WechatAccount.find_by(authorizer_appid: params[:shop_id])
            if @wechat_account.present?
              @current_shop = @wechat_account.shop
              content_hash = message_decrypt
              # location 特殊处理+
              message_params = MessageReception.get_message_params_from_hash(content_hash, true)
              if message_params[:msg_type] == 'event' && message_params[:event] == 'LOCATION'
                WeixinLocationMessageWorker.perform_in(1.second, @current_shop.id, message_params)
                head :ok
                return
              end
              @message = Ddt::MessageReception.create_from_hash(@current_shop, content_hash)
              if @message.blank?
                Rails.logger.info "message blank, content_hash: #{content_hash}"
                head :ok
                return
              end
            else
              head :ok
              return
            end
          end
        else
          set_current_shop
          if params[:encrypt_type] == 'aes'
            # 过滤掉加密的消息
            head :ok
            return
          else
            result  = (set_message && set_wechat_account && validate_weixin_signature)
            # 如果以下三个方法有不是true的，说明render方法已经被调用，应该终止该动作的执行。
            return unless result
          end
        end
        update_wechat_subscribe_relationship
        set_wechat_user
        @message_response = get_message_response_from_message_handle
        if @message_response.present?
          if @message_response.is_a? Ddt::MessageResponse
            if message_for_authorized_wechat_account?
              render xml: message_encrypt(@message_response.to_response_xml), status: 200
            else
              render xml: @message_response.to_response_xml, status: 200
            end
          elsif @message_response.is_a? Ddt::KeywordsThirdPartyInterface
            render xml: @message_response.send_message(request, params), status: 200
          else
            Rails.logger.info "1 message response empty, message: #{@message.to_log_info}"
            head :ok
          end
        else
          Rails.logger.info "2 message response empty, message: #{@message.to_log_info}"
          head :ok
        end
      end

      def validate
        if @current_shop.present?
          @current_shop.wechat_accounts.each do |wechat_account|
            if Ddt::MessageReception.validate_message_signature?(wechat_account.try(:token), params[:timestamp], params[:nonce], params[:signature])
              render inline: params[:echostr]
              return
            end
          end
        end
        head :ok
      end


      private
      # 目前 set_wechat_account, validate_weixin_signature, set_message 方法已不再作为filter使用，
      # 增加布尔类型返回值，如果返回值是false则内部已经执行过render方法。。

      def set_wechat_account
        @wechat_account = @message.wechat_account
        if @wechat_account.blank?
          render xml: @message.response("公众号没有在点单通后台配置或者已经被删除，请确认已经在点单通后台绑定。").to_response_xml, status: 200
          false
        else
          true
        end
      end

      def validate_weixin_signature
        if Ddt::MessageReception.validate_message_signature?(@wechat_account.token, params[:timestamp], params[:nonce], params[:signature])
          true
        else
          head :ok
          false
        end
      end

      def update_wechat_subscribe_relationship
        if @message.from_user_name.nil?
          Rails.logger.error 'from_user_name 不能为空值'
          return
        end
        Ddt::WechatSubscribeRelationship.add_relationship(@message.to_user_name, @message.from_user_name)
      end

      def set_wechat_user
        @wechat_user = @message.wechat_user
      end

      def set_message
        message_params = MessageReception.get_message_params_from_request(request, true)
        if message_params[:msg_type] == 'event' && message_params[:event] == 'LOCATION'
          WeixinLocationMessageWorker.perform_in(1.second, @current_shop.id, message_params)
          head :ok
          false
        else
          @message = MessageReception.create_from_request(@current_shop, request)
          if @message.blank?
            head :ok
            false
          else
            true
          end
        end
      end

      def get_message_response_from_third_part_interface
        nil
      end

      def get_message_response_from_message_handle
        Ddt::MessageHandler.new(@message).build_message
      end

      def message_for_authorized_wechat_account?
        params[:shop_id] =~ /\Awx[a-zA-Z0-9]{16}\Z/i
      end

      def message_decrypt
        xml_content = wx_msg_crypt.DecryptMsg(request.body.read, params[:msg_signature], params[:timestamp], params[:nonce])
        Hash.from_xml(xml_content).to_options[:xml].to_options
      end

      def message_encrypt(xml)
        wx_msg_crypt.EncryptMsg(xml, params[:nonce], params[:timestamp])
      end

      def wx_msg_crypt
        Ddt::WeixinCrypt::WXBizMsgCrypt.new(
          Ddt::WeixinConfig.gonghao.component_token,
          Ddt::WeixinConfig.gonghao.component_encoding_ase_key,
          Ddt::WeixinConfig.gonghao.component_appid
        )
      end

      def is_weixin_test?
        params[:shop_id] == Ddt::WeixinConfig.gonghao.component_test_appid
      end

      def handle_weixin_test
        shop = Ddt::Shop.find('ddt')
        content_hash = message_decrypt
        message = Ddt::MessageReception.create_from_hash(shop, content_hash)
        if message.msg_type == 'event'
          message_response = message.response("#{message.event}from_callback")
        elsif message.msg_type == 'text'
          if message.content == "TESTCOMPONENT_MSG_TYPE_TEXT"
            message_response = message.response("TESTCOMPONENT_MSG_TYPE_TEXT_callback")
          elsif message.content =~ /^QUERY_AUTH_CODE:(.+)$/
            query_auth_code = $1
            component_access_token = Ddt::WechatComponent.instance.get_component_access_token
            component_appid = Ddt::WeixinConfig.gonghao.component_appid
            authorizer_access_token = Ddt::WeixinApi.get_component_auth_info(component_access_token, component_appid, query_auth_code)[:authorization_info].to_options[:authorizer_access_token]
            Ddt::WeixinTestCustomMessageWorker.perform_in(1.second, message.from_user_name, authorizer_access_token, query_auth_code)
            head :ok
            return
          end
        end
        render xml: message_encrypt(message_response.to_response_xml), status: 200
      end
    end
  end
end
