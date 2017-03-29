module Ddt
  class Backend::VipSearchesController < Backend::BaseController
    check_permission :shop, :user, :show
    before_action :set_filter, only: [:destroy, :compute, :recompute, :export, :get_send_coupon, :send_coupon, :show_logs]

    def index
      @search_filters = @current_shop.search_filters.by_type('Ddt::VipInfo').paginate(page: params[:page])
    end

    def new
      @vip_levels = @current_shop.vip_levels
      @vip_search = Ddt::VipSearch.new
    end

    def create
      @filter = @current_shop.search_filters.build(model_type: 'Ddt::VipInfo')
      if Ddt::VipSearch.persistence(@filter, params[:vip_search])
        redirect_to :action => :index
      else
        flash[:error] = "输入非法"
        redirect_to :action => :index
      end
    end

    def destroy
      @filter.destroy
      redirect_to :action => :index
    end

    def compute
      @filter.start_compute
      redirect_to :action => :index
    end

    def recompute
      @filter.start_recompute
      redirect_to :action => :index
    end

    def export
      result = @filter.last_result
      respond_to do |format|
        format.csv{
          if result.present?
            if result.model_ids.present?
              send_data @current_shop.vip_infos.where(id: result.model_ids).to_csv
            else
              send_data 'empty result'
            end
          else
            send_data 'illegle'
          end
        }
      end
    end

    def get_send_coupon
      result = @filter.last_result
      if result.present?
        if result.model_ids.size > 0
          send_user_ids = @current_shop.users.where(vip_info_id: result.model_ids).pluck(:id)
          @send_coupon_form = Ddt::SendCouponForm.new(
          coupon_version_id: @current_shop.coupon_versions.first.try(:id),
          count: 1,
          base_user_ids: send_user_ids.join(','))
        end
      end
    end

    def send_coupon
      @send_coupon_form = Ddt::SendCouponForm.new(params[:send_coupon_form].merge(shop: @current_shop))
      if @send_coupon_form.valid?
        result = @filter.last_result
        base_user_ids = params[:send_coupon_form][:base_user_ids].split(",")
        attrs = params[:send_coupon_form].merge!(
          to_user_ids: base_user_ids,
          shop_id: @current_shop.id,
          caller_type: result.class.name,
          caller_id: result.id
        )
        Ddt::SendCouponWorker.perform_in(1.second, attrs)
        render :send_coupon
      else
        render :get_send_coupon
      end
    end

    def show_logs
      @logs = @filter.search_results.order(:updated_at).pluck(:log).map{|l| l.present? ? l.gsub("\n", "<br />") : ''}
    end

    private

      def set_filter
        @filter = @current_shop.search_filters.find(params[:id])
      end

  end
end
