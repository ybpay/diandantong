# encoding:utf-8
require 'singleton'
module Ddt
  class WechatComponent
    class WeixinComponentError < ::StandardError
    end
    include Singleton
    attr_accessor :system_wechat_account, :gonghao_config
    delegate :component_verify_ticket,
             :component_access_token, :component_access_token_expired_at,
             :pre_auth_code, :pre_auth_code_expired_at, to: :system_wechat_account
    delegate :component_appid, :component_appsecret, to: :gonghao_config
    def initialize
      self.system_wechat_account = Ddt::WechatAccount.system_wechat_account
      self.gonghao_config = Ddt::WeixinConfig.gonghao
    end

    def get_component_oauth_url(shop_id)
       p = {
        component_appid: WeixinConfig.gonghao.component_appid,
        pre_auth_code: self.get_component_pre_auth_code,
        redirect_uri: "http://#{WeixinConfig.gonghao.component_authroized_domain}/common/wechat_account_oauth_callback?shop_id=#{shop_id}"
      }
      "https://mp.weixin.qq.com/cgi-bin/componentloginpage?#{p.to_query}"
    end

    def update_component_verify_ticket(new_ticket)
      system_wechat_account.update!(
        component_verify_ticket: new_ticket,
        last_update_component_verify_ticket_at: Time.now
      )
    end

    def get_component_access_token
      system_wechat_account.reload
      if component_verify_ticket.present?
        if component_access_token.present? && component_access_token_expired_at.present? && component_access_token_expired_at > Time.now
          # 未过期
          component_access_token
        else
          # 已过期
          new_component_access_token, expires_in = WeixinApi.get_component_access_token(component_appid, component_appsecret, component_verify_ticket)
          system_wechat_account.update!(component_access_token: new_component_access_token, component_access_token_expired_at: expires_in.seconds.from_now) if new_component_access_token.present?
          new_component_access_token
        end
      else
        raise WeixinComponentError, "no component_verify_ticket"
      end
    end

    def expire_pre_auth_code
      system_wechat_account.update!(pre_auth_code_expired_at: Time.now)
    end

    def get_component_pre_auth_code
      # 只能使用一次
      if pre_auth_code.present? && pre_auth_code_expired_at.present? && pre_auth_code_expired_at > Time.now
        # 未过期
        pre_auth_code
      else
        # 已过期
        new_pre_auth_code, expires_in = WeixinApi.get_component_pre_auth_code(get_component_access_token, component_appid)
        system_wechat_account.update!(pre_auth_code: new_pre_auth_code, pre_auth_code_expired_at: expires_in.seconds.from_now) if new_pre_auth_code.present?
        new_pre_auth_code
      end
    end

    def create_wechat_account_after_auth(shop_id, auth_code)
      shop = Ddt::Shop.find(shop_id)
      auth_info = WeixinApi.get_component_auth_info(get_component_access_token, component_appid, auth_code)[:authorization_info].to_options
      wechat_account = shop.wechat_accounts.find_by(app_id: auth_info[:authorizer_appid])
      params = {
        is_authorized: true,
        authorizer_appid: auth_info[:authorizer_appid],
        authorizer_access_token: auth_info[:authorizer_access_token],
        authorizer_access_token_expired_at: auth_info[:expires_in].seconds.from_now,
        authorizer_refresh_token: auth_info[:authorizer_refresh_token],
        preferred_auth_info: auth_info.to_s
      }
      if wechat_account.present?
        wechat_account.update!(params)
      else
        wechat_account = shop.wechat_accounts.create!(params)
      end
      wechat_account
    end
  end
end