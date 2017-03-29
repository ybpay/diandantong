#encoding: utf-8
module Ddt
  module TrackFrom
    extend ActiveSupport::Concern
    THREAD_KEY = :__track_from__

    BACKEND  = "FromBackend"
    WECHAT   = "FromWechat"
    MOBILE = "FromMobile"
    WEBPOS   = "FromWebpos"
    WIFI     = "FromWifi"
    APP      = "FromApp"
    WEBSTORE = "FromWebstore"
    AGENT    = "FromAgent"
    UNKNOW   = "FromUnknow"

    BACKEND_LABEL  = "后台"
    WECHAT_LABEL   = "微信"
    MOBILE_LABEL   = "手机浏览器"
    WEBPOS_LABEL   = "收银端"
    WIFI_LABEL     = "Wifi堂点"
    APP_LABEL      = "App"
    WEBSTORE_LABEL = "网站"
    AGENT_LABEL    = "代理商"
    UNKNOW_LABEL   = "未知"


    def self.current
      RequestStore.store[THREAD_KEY]
    end


    included do
      before_create :set_track_from

      def self.current_track_from
        RequestStore.store[THREAD_KEY]
      end

    end

    def set_track_from
      self.track_from = self.track_from || self.class.current_track_from || UNKNOW
    end

  end
end
