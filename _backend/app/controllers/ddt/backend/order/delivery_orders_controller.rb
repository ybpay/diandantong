module Ddt
  class Backend::Order::DeliveryOrdersController < Backend::BaseController
    include Backend::BaseOrderController
    before_action :set_order, except: [:index, :assigned]
    check_permission :branch, :order, {
      [:show, :other_msg, :index, :assigned] => :show,
      :confirm => :confirm,
      :complete => :complete,
      :cancel => :cancel,
      [:get_reprint, :chooseable_printers, :reprint] => :reprint,
      [:pay_by_default_method] => :settle,
      [:get_append_pay_item, :append_pay_item, :destroy_pay_item, :clear_appended] => :append_pay_item,
    }, except: [:get_assign, :assign, :start, :ship]
    check_permission :branch, :delivery_order, {
      :get_assign => :assign_delivery_man,
      :assign => :assign_delivery_man,
      :start => :start_shipment,
      :ship => :finish_shipment,
    }, only: [:get_assign, :assign, :start, :ship]

    def index
      deal_params
      # limit @order_collection.unassign
      limit @order_collection.where(delivery_man_id_null: true)
      set_search_url [:backend, @current_shop, :delivery_orders]
      render orders_index
    end

    def assigned
      # limit @order_collection.assigned

      limit @order_collection.where(delivery_man_id_not_null: true)
      set_search_url [:assigned, :backend, @current_shop, :delivery_orders]
      render orders_index
    end

    def get_assign
      b = @order.branch
      @deliverymans = b.deliverymans
      @branch_msg = {lng: b.longitude, lat: b.latitude, label: "门店: #{b.name}"}
      @locations = @current_shop.deliveryman_locations(@deliverymans)
      @man_msgs = []
      @deliverymans.each do |delivery_man|
        location = @locations.detect{|location| location.owner_id == delivery_man.id }
        if location.present?
          @man_msgs << {lng: location.longitude, lat: location.latitude, label: "#{delivery_man.name}"}
        else
          @man_msgs << {lng: 0, lat: 0, label: "#{delivery_man.name}"}
        end
      end
      @user_msg = nil
      if @order.latitude && @order.longitude
        @user_msg = {lng: @order.longitude, lat: @order.latitude, label: "顾客: #{@order.delivery_name}, #{@order.delivery_phone}, #{@order.delivery_address}"}
      end
      @map_json = { start: @branch_msg, desti: @user_msg, mans: @man_msgs}.to_json
      respond_to do |format|
        format.js { render 'get_assign'}
      end
    end

    def assign
      @order.assign_delivery_man(params[:delivery_man_id])
      respond_to do |format|
        format.js { render reset_table_tr }
      end
    end

    def start
      @order.start_shipment
      respond_to do |format|
        format.js { render reset_table_tr}
      end
    end

    def ship
      @order.ship_shipment
      respond_to do |format|
        format.js { render reset_table_tr }
      end
    end

    private

      def deal_params
        if params[:q].blank?
          params[:q] = { type_eq: "Ddt::DeliveryOrder"}
        elsif params[:q][:type_eq].blank?
          params[:q][:type_eq] = "Ddt::DeliveryOrder"
        end
      end

      def set_search_url(path_array)
        @search_url = url_for(path_array.push(host: Rails.application.default_url_options[:host]))
      end

      def limit(orders)
        @q = orders.accessible_by(current_account).order(placed_at: :desc).where(params[:q])
        @per_page = params[:q].try("[]", :per_page) || 20
        @orders = @q.result(distinct: true).paginate(page: params[:page], per_page: @per_page).query.relation_includes(:branch, :user)
      end

      def set_order_collection
        @order_collection = @current_shop.delivery_orders
      end

      def orders_index
        '/ddt/backend/orders/index'
      end

      def reset_table_tr
        '/ddt/backend/order/reset_table_tr'
      end
  end
end
