# encoding:utf-8
module Ddt
  module Backend
    module OrdersHelper
      def order_type_label(order)
        icon_class, label_class = case order.type_str.to_sym
                            when :delivery
                              ['fa fa-truck', 'btn-info']
                            when :reservation
                              ['fa fa-calendar', 'btn-yellow']
                            when :eat_in_hall
                              ['fa fa-cutlery', 'btn-purple']
                            when :fastfood
                              ['fa fa-delicious', 'btn-purple']
                            when :groupon
                              ['fa fa-cc', 'btn-danger']
                            when :recharge
                              ['fa fa-money', 'btn-warning']
                            when :payment
                              ['fa fa-money', 'btn-success']
                            end
        content_tag(:span, order.type_name)
      end
      def order_state_label(order)
        content_tag(:span, order.state_name)
      end

      def order_user_cancel_info(order)
        user = order.user
        if user.present?
          count = user.continuous_cancel_order_count
          if order.is_canceled?
            # 用户已被屏蔽
            span = if user.is_blocked
              content_tag(:span, "已禁止用户下单", class: "label label-default")
            # 用户连续多次取消订单，但还未被屏蔽
            elsif count > Ddt::BaseUser::CONTINUOUS_CANCEL_LIMIT
              content_tag(:span, "该用户连续 #{count} 次取消订单", class: "label label-warning")
            end
            link_to span, edit_backend_shop_base_user_path(@current_shop, user) if span.present?
          end
        end
      end

      def pay_item_state_label(order)
        html = []
        html << content_tag(:span, order.pay_item_state_name) if order.pay_item_state.present?
        html << order.pay_method_name
        if order.paid? && order.pay_items.any?{|p| p.is_append? }
          class_name = "btn btn-xs btn-no-border #{order.total != order.pay_item_total ? 'label-danger' : 'label-success'}"
          html << content_tag(:span, '调', class: class_name)
        end
        html.join("<br />")
      end

      def shipment_state_label(order)
        return if order.shipment_state.blank?
        label_class = case order.shipment_state.to_sym
                      when :pending
                        'label-primary'
                      when :shipping
                        'label-info'
                      when :shipped
                        'label-success'
                      when :canceled
                        'label-default'
                      else
                        'label-default'
                      end
        content_tag(:span, order.shipment_state_name, class: "label #{label_class}")
      end

      def order_actions(order, options={})
        size = options[:size] || :small
        case size
        when :small
          btn_size_class = 'btn-xs'
          options[:show_label] = false
        when :normal
          btn_size_class = ''
          options[:show_label] = true
        end

        paid_html = ""
        unless order.paid? or order.canceled? or order.refunded?
          pay_by_default_url = url_for([:pay_by_default_method, :backend, @current_shop, order.branch, order]) + query_str
          paid_html = remote_link_tag(pay_by_default_url,
                                      "btn #{btn_size_class} btn-danger",
                                      'fa fa-rmb', '已付款',
                                      {
                                          :'data-confirm'=>"确认设置该订单为以#{order.default_pay_method_name}方式完成支付吗？",
                                          :'format' => 'js'
                                      }.merge(options)
          )
        end
        actions = order.allow_actions
        actions_html = actions.map do |action|
          url = url_for([action, :backend, @current_shop, order.branch, order]) + query_str
          case action
          when :confirm  ;
            remote_link_tag(url, "btn #{btn_size_class} btn-primary", "fa fa-check", "确认", options);
          when :complete ;
            remote_link_tag(url, "btn #{btn_size_class} btn-success", "fa fa-circle-o", "完成", options);
          when :cancel   ;
            real_link = remote_link_tag(url, "btn #{btn_size_class} real_cancel_link", "fa fa-remove", "取消", options.merge(style: 'display:none;') );
            fake_link = remote_link_tag("javascript:void(0);", "btn #{btn_size_class} fake_cancel_link", "fa fa-remove", "取消", options.merge(remote: false) );
            "#{fake_link}#{real_link}"
          end
        end.join(' ') if actions.present?

        [paid_html, actions_html].join(' ').html_safe
      end


      def shipment_actions(order)
        actions = {
           pending: [:start],
          shipping: [:ship],
           shipped: [],
          canceled: []
        }[order.shipment_state.to_sym]

        actions.map do |action|
          url = url_for([action, :backend, @current_shop, order.branch, order])
          case action
          when :start ; remote_link_tag(url, "btn btn-xs btn-info", "fa fa-bicycle", "改为送货中");
          when :ship  ; remote_link_tag(url, "btn btn-xs btn-success", "fa fa-angellist", "改为已送达");
          end
        end.join(' ').html_safe
      end

      def address_map(order)
        if order.lat_lng_present?
          latitude, longitude = order.lat_lng
          if @current_shop.enable_foreign
            url = "https://maps.googleapis.com/maps/api/staticmap?size=340x200&center=#{latitude},#{longitude}&zoom=13&markers=color:green%7C#{latitude},#{longitude}"
          else
            url = "http://st.map.qq.com/api?size=340*200&center=#{longitude},#{latitude}&zoom=13&markers=#{longitude},#{latitude},green"
          end
          raw "<img src='#{url}' />"
        end
      end

      def navigate_link(order)
        if order.lat_lng_present?
          branch = order.branch
          latitude, longitude = order.lat_lng
          content  = order.delivery_address
          if @current_shop.enable_foreign
            url = "https://www.google.com/maps/place/#{latitude},#{longitude}"
          else
            url = "http://apis.map.qq.com/uri/v1/routeplan?type=drive&fromcoord=#{branch.latitude},#{branch.longitude}&tocoord=#{latitude},#{longitude}&to=#{content}&referer=点单通"
          end
          raw "<a href='#{url}' target='_blank'>地图导航</a>"
        end
      end

      def remote_link_tag(url, link_class, tag_class, title, append_opts={})
        classes = link_class.split(' ')
        html_class = classes.select{|c| c.present? && !c.start_with?('btn')}.join(' ')
        link_to "#{title}", url, {method: :put, remote: true, :'data-rel' => "tooltip", class: html_class, title: title}.merge(append_opts)
      end

      def query_str
        "?show_delivery_man=#{can_show_delivery_man?}"
      end

      def can_show_delivery_man?
        return @show_delivery_man ||= to_bool(params[:show_delivery_man]) if params[:show_delivery_man].present?
        return @show_delivery_man ||= (controller_name == 'delivery_orders' && action_name != 'append')
      end

      def can_change_state?
        return @can_change_state ||= not_deliveryman?
      end

      def can_assign_delivery_man?(order)
        return to_bool(params[:show_delivery_man]) if params[:show_delivery_man].present?
        return controller_name=='delivery_orders' && action_name != 'append' && ([:confirmed].include? order.state.to_sym) && has_assign_privilege? && !(order.completed? or [:shipping, :shipped].include? order.shipment_state.to_sym)
        
      end

      def can_change_shipment_state?(order)
        return controller_name=="delivery_orders" && order.assign_delivery_man?
      end

      def has_assign_privilege?
        return current_account.can?(:branch, :delivery_order, :assign_delivery_man)
      end

      def not_deliveryman?
        return !current_account.is_deliveryman?
      end

      def to_bool(str)
        str == "true" ? true : false
      end

      def is_search_reservation_order?
        return false if @q.blank?
        @q.form_model.type_eq=="Ddt::ReservationOrder"
      end

      def is_search_eatinhall_order?
        return false if @q.blank?
        @q.form_model.type_eq=="Ddt::EatInHallOrder"
      end

    end
  end
end
