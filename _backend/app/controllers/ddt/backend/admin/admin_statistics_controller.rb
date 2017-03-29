module Ddt
  module Backend
    class Admin::AdminStatisticsController < Backend::BaseAdminController
      layout 'ddt/layouts/backend/admin_statistics'
      before_action :set_query_params, only: [:visit_data, :order_data, :order_types, :order_origins, :pay_types, :queue_origins, :notification_data, :shop_data]
      before_action :set_tick_interval, only: [:visit_data, :order_data, :order_types, :order_origins, :pay_types, :queue_origins, :notification_data, :shop_data]
      before_action :set_empty_data, only: [:visit_data, :order_data, :order_types, :order_origins, :pay_types, :queue_origins, :notification_data, :shop_data]
      def index
        redirect_to action: :visit_data
      end

      def visit_data
        @time_column = "impressions.created_at"
        @data = Impression.where(created_at: @start_date..@end_date).order(:created_at).group(group_string(@time_column)).count
        @data = @empty_data.merge(@data)
      end

      def order_data
        @data = OrderService::Api::Statistic.order_quantity(query: { placed_at_gteq: @start_date.beginning_of_day, placed_at_lteq: @end_date.end_of_day}, group_by: "placed_at_#{@interval}")
        @data = @empty_data.merge(@data)
      end

      def order_types
        result = OrderService::Api::Statistic.order_quantity(query: { placed_at_gteq: @start_date.beginning_of_day, placed_at_lteq: @end_date.end_of_day}, group_by: [:type, "placed_at_#{@interval}"])
        @datas = result.map do |key, value|
          {
            name: "#{OrderService::Order::Base.type_name(key)}订单",
            data: @empty_data.merge(value).values
          }
        end
        @datas << summary_result(@datas)
      end

      def pay_types
        result = OrderService::Api::Statistic.order_quantity(query: { paid_at_gteq: @start_date.beginning_of_day, paid_at_lteq: @end_date.end_of_day, pay_method_present: 1}, group_by: [:pay_method, "paid_at_#{@interval}"])
        @datas = result.map do |key, value|
          {
            name: OrderService::Order::Base.pay_method_name(key),
            data: @empty_data.merge(value).values
          }
        end
        @datas
      end

      def order_origins
        result = OrderService::Api::Statistic.order_quantity(query: { placed_at_gteq: @start_date.beginning_of_day, placed_at_lteq: @end_date.end_of_day}, group_by: [:track_from, "placed_at_#{@interval}"])
        @datas = result.map do |key, value|
          {
            name: OrderService::Order::Base.track_from_name(key),
            data: @empty_data.merge(value).values
          }
        end
        @datas << summary_result(@datas)
      end

      def queue_origins
        @time_column = "ddt_guest_queues.created_at"
        @track_froms = [
          { track_from: 'FromWechat',   name: '微信排号'},
          { track_from: 'FromWebpos',   name: '收银端排号'},
          { track_from: 'FromApp',      name: 'App排号'},
          { track_from: 'FromWifi',     name: 'Wifi堂点'}
        ]
        @datas = @track_froms.map do |item|
          data = Ddt::GuestQueue.where(track_from: item[:track_from], created_at: @start_date..@end_date).group(group_string(@time_column)).count
          data = @empty_data.merge(data)
          { name: item[:name], data: data.values}
        end
        @datas << summary_result(@datas)
      end

      def notification_data
        @time_column = "ddt_notification_actions.created_at"
        @types = [
          { type: 'Ddt::Notification::Action::App'          , name: 'App消息'}  ,
          { type: 'Ddt::Notification::Action::Backend'      , name: '后台消息'}   ,
          { type: 'Ddt::Notification::Action::Email'        , name: '邮件消息'}   ,
          { type: 'Ddt::Notification::Action::Printer'      , name: '打印消息'}   ,
          { type: 'Ddt::Notification::Action::Sms'          , name: '短信消息'}   ,
          { type: 'Ddt::Notification::Action::SystemWeixin' , name: '系统微信消息'} ,
          { type: 'Ddt::Notification::Action::Webpos'       , name: '收银端消息'}  ,
          { type: 'Ddt::Notification::Action::Weixin'       , name: '普通微信消息'} ,
        ]
        @datas = @types.map do |n|
          data = Ddt::NotificationAction.where(type: n[:type], created_at: @start_date..@end_date).group(group_string(@time_column)).count
          data = @empty_data.merge(data)
          { name: n[:name], data: data.values }
        end
        @datas << summary_result(@datas)
      end

      def shop_data
        @time_column = "ddt_shops.created_at"
        @data = Ddt::Shop.where(created_at: @start_date..@end_date).group(group_string(@time_column)).count
        @data = @empty_data.merge(@data)
      end

      private

      def summary_result(datas)
        { name: "合计", data: @empty_data.values.zip(*datas.map{|item| item[:data]}).map(&:sum)}
      end

      def set_query_params
        params[:query] = {} if params[:query].blank?
        params[:query][:start_date] = Date.today.beginning_of_month.to_date.strftime("%F") if params[:query][:start_date].blank?
        params[:query][:end_date] = Date.today.end_of_month.to_date.strftime("%F") if params[:query][:end_date].blank?
        params[:query][:interval] = :day if params[:query][:interval].blank?
        @start_date = params[:query][:start_date].is_a?(Date) ? params[:query][:start_date] : Date.parse(params[:query][:start_date]).to_date
        @end_date = params[:query][:end_date].is_a?(Date) ? params[:query][:end_date] : Date.parse(params[:query][:end_date]).to_date
        @interval = params[:query][:interval].to_sym
      end

      def set_tick_interval
        t = { day: 10, month: 300, year: 3000 }[@interval]
        @tick_interval = ((@end_date - @start_date).to_i * 1.0 / t).ceil
      end

      def set_empty_data
        @empty_data = ActionController::Parameters.new(
          case @interval
          when :day
            Hash[(@start_date..@end_date).map { |v| [v.strftime('%m-%d'), 0] }]
          when :month
            Hash[(@start_date..@end_date).map(&:beginning_of_month).uniq.map{|m| [m.strftime('%Y-%m'), 0]}]
          when :year
            Hash[(@start_date..@end_date).map(&:beginning_of_year).uniq.map{|m| [m.strftime('%Y'), 0]}]
          end
        )
      end

      def group_string(time_column)
        case @interval
        when :day
          "DATE_FORMAT(#{time_column}, '%m-%d')"
        when :month
          "DATE_FORMAT(#{time_column}, '%Y-%m')"
        when :year
          "DATE_FORMAT(#{time_column}, '%Y')"
        end
      end
    end
  end
end
