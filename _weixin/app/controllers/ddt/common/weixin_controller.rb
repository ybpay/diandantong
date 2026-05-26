# encoding : utf-8
module Ddt
  module Common
    class WeixinController < ApplicationController
      protect_from_forgery :except => [:weixin_oauth_callback, :wechat_account_oauth_callback, :wechat_server_auth_file]

      def weixin_oauth_callback
        wx_msg_crypt = Ddt::WeixinCrypt::WXBizMsgCrypt.new(
          Ddt::WeixinConfig.gonghao.component_token,
          Ddt::WeixinConfig.gonghao.component_encoding_ase_key,
          Ddt::WeixinConfig.gonghao.component_appid
        )
        xml_content = wx_msg_crypt.DecryptMsg(request.body.read, params[:msg_signature], params[:timestamp], params[:nonce])
        hash = Hash.from_xml(xml_content).to_options[:xml].to_options
        if hash[:ComponentVerifyTicket].present?
          # 推送 ComponentVerifyTicket
          Ddt::WechatComponent.instance.update_component_verify_ticket(hash[:ComponentVerifyTicket])
          render plain: 'success'
        elsif hash[:AuthorizerAppid].present?
          # 取消授权
          wechat_account = Ddt::WechatAccount.find_by(authorizer_appid: hash[:AuthorizerAppid])
          wechat_account.cancel_authorize if wechat_account.present?
          render plain: 'success'
        end
      end

      def wechat_account_oauth_callback
        if params[:auth_code].present?
          shop = Ddt::Shop.find(params[:shop_id])
          wechat_account = WechatComponent.instance.create_wechat_account_after_auth(params[:shop_id], params[:auth_code])
          wechat_account.update_authorizer_info
          WechatComponent.instance.expire_pre_auth_code
          redirect_to "/backend/shops/#{shop.slug}/wechat_accounts"
        else
          render plain: 'error'
        end
      end

      def wechat_server_auth_file
        account = Ddt::WechatAccount.find_by(server_auth_file: "MP_#{params[:hash]}.txt")
        if account.present?
          render plain: open(account.server_auth_file.url).read
        else
          head 404
        end
      end

    end
  end
end