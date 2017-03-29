# encoding: utf-8
module Ddt
  module Backend
    module UserWalletsHelper
      def get_recharge_btn(user_wallet, options={})
        link_to tag(:icon, class: "fa fa-plus"),
                "#{url_for([:get_recharge, :backend, @current_shop, user_wallet])}?#{options.to_query}",
                class: "btn btn-xs btn-success no-border",
                title: "充值",
                remote: true,
                method: :get
      end

      def get_exchange_btn(user_wallet, options={})
        link_to tag(:icon, class: "fa fa-exchange"),
                "#{url_for([:get_exchange, :backend, @current_shop, user_wallet])}?#{options.to_query}",
                class: "btn btn-xs no-border btn-purple",
                title: "兑换",
                remote: true,
                method: :get
      end

      def user_wallet_logs_btn(user_wallet, options={})
        link_to tag(:icon, class: "fa fa-list"),
                "#{url_for([:wallet_logs, :backend, @current_shop, user_wallet])}?#{options.to_query}",
                class: "btn btn-xs btn-info no-border",
                  title: "日志"
      end
    end

  end
end
