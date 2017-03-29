#encoding: utf-8
module Ddt
  module Backend
    module VipSearchesHelper
      def filter_state_info(filter)
        html = ""
        html << content_tag(:span, filter.state_name)
        if filter.is_computing?
          html << content_tag(:br)
          html << content_tag(:span) do
            "<预计完成时间: #{(filter.updated_at + 4.hours).strftime("%Y-%m-%d %H:%M")}>"
          end
        end
        if filter.is_completed?
          html << content_tag(:br)
          html << content_tag(:span) do
            "<共找到: #{filter.last_result.try(:count)}条记录>"
          end
        end
        raw html
      end

      def filter_btns(filter)
        btns = []
        if filter.is_init?
          btns << (link_to '开始计算', compute_backend_shop_vip_search_path(@current_shop, filter), method: :post)
        end
        if filter.is_completed?
          btns << (link_to '重新计算', recompute_backend_shop_vip_search_path(@current_shop, filter), method: :post)
          if filter.last_result.count > 0
            btns << (link_to '导出数据', export_backend_shop_vip_search_path(@current_shop, filter, format: :csv))
            btns << (link_to '送优惠券', get_send_coupon_backend_shop_vip_search_path(@current_shop, filter), remote: true)
            btns << (link_to '日志', show_logs_backend_shop_vip_search_path(@current_shop, filter), remote: true)
          end
        end
        unless filter.is_computing?
          btns << (link_to '删除', backend_shop_vip_search_path(@current_shop, filter), method: :delete)
        end
        raw btns.join("&nbsp;")
      end

    end
  end
end
