module Ddt
  class Backend::OrdersController < Backend::BaseController
    layout 'ddt/layouts/backend/order'
    before_action :set_anti_settlements_params, only: [:anti_settlements]
    include BatchChangeOrderState
    include Backend::PaginateExportAll
    before_action :set_order, only: [:print, :show]
    before_action :authorize_order, except: [:index]
    etag{ current_account.id }
    def index
      @search_url = url_for([:backend, @current_shop, :orders, host: Rails.application.default_url_options[:host]])
      @per_page = params[:q].try("[]", :per_page) || 20
      @orders = @q.includes(:pay_items, :form_contents, :adjustments).paginate(page: params[:page], per_page: @per_page).query.relation_includes(:branch, :user)
      fresh_when(@orders)
    end

    def print
    end

    def batch_change_state
      batch_change_order_state do |errors|
        if errors.present?
          flash[:error] = errors.join(", ")
        else
          flash[:success] = '状态修改成功'
        end
      end
      redirect_to backend_shop_orders_path(@current_shop, params: filted_params, flash: flash)
    end

    def batch_change_pay_item_state
      batch_change_order_pay_item_state do |errors|
        if errors.present?
          flash[:error] = errors.join(", ")
        else
          flash[:success] = '状态修改成功'
        end
      end
      redirect_to backend_shop_orders_path(@current_shop, params: filted_params, flash: flash)
    end

    def export_selected
      export_to_csv(orders)
    end

    def export_all
      @orders = @q.includes(:line_items, :pay_items, :form_contents, :adjustments).paginate(page: params[:page], per_page: params[:per_page]).query.relation_includes(:branch)
      export_to_csv(@orders)
    end

    def show
      redirect_to "/backend/shops/#{@current_shop.slug}/branches/#{@order.branch.id}/#{@order.type_str}_orders/#{@order.id}"
    end

    def set_anti_settlements_params
      params[:q] = {} unless params[:q].present?
      params[:q][:anti_settlement_eq] = true
    end

    def anti_settlements
      @search_url = url_for([:anti_settlements, :backend, @current_shop, :orders, host: Rails.application.default_url_options[:host]])
      @orders = @q.includes(:pay_items, :form_contents, :adjustments).paginate(page: params[:page], per_page: params[:per_page]).query.relation_includes(:branch, :user)
      render '/ddt/backend/orders/index'
    end

    private
    def filted_params
      ps = super
      ps.delete(:order)
      ps
    end

    def search
      set_shop_orders
      @q = @shop_orders.accessible_by(current_account).order(placed_at: :desc).where(params[:q].try(:except, :per_page))
    end

    def per_page
      50
    end

    def set_export_all_path
      @export_all_path = export_all_backend_shop_orders_path(@current_shop, format: "csv", params: params)
    end

    def export_to_csv(export_orders)
      suffix = params[:page].present? ? "_part_#{params[:page]}" : ""
      respond_to do |format|
        format.csv { send_data Ddt::OrderFormat::Csv.content(export_orders, col_sep: ","), :filename => "orders#{suffix}.csv" }
      end
    end

    def set_shop_orders
      set_order_type
      @shop_orders ||= @current_shop.orders
    end

    def set_order_type
      if params[:q].blank? || params[:q][:type_eq].blank?
        @order_type = :all
      else
        @order_type = params[:q][:type_eq].demodulize.underscore.to_sym
      end
    end

    def set_order
      @order = @current_shop.orders.find(params[:id])
    end

    def deal_result(result)
      details = {}
      template = {}
      template[:branch_name] = ""
      OrderService::Order::Base.pay_method_values.each do |pay_method|
        template[pay_method] = 0
      end
      template[:total] = 0

      sum = template.dup
      result.each do |item|
        key = item.branch_id.to_s
        if details[key] == nil
          details[key] = template.dup
          details[key][:branch_name] = item.branch.name
        end
        # 有遗留数据是没有 pay_method 的，把它们归到 :pay_on_receive 中。
        pay_method  = item.pay_method.try(:to_sym) || :pay_on_receive

        details[key][pay_method] = item.total
        details[key][:total] += item.total
        sum[pay_method] += item.total
        sum[:total] += item.total
      end
      details.merge(sum: sum)
    end

    def authorize_order
      actions = {
        [:print, :export_selected, :export_all, :show, :get_export_list] => :show,
        batch_change_state: :batch_change_state,
        [:batch_change_pay_item_state, :set_anti_settlements_params, :anti_settlements] => :settle,
      }
      permission_action = nil
      actions.each do |key, value|
        if (key.is_a?(Array) && key.include?(action_name.to_sym)) || ( key == action_name.to_sym )
          permission_action = value
        end
      end
      permission_action = action_name.to_sym if permission_action.blank?
      authorize!(:branch, :order, permission_action)
    end
  end
end

