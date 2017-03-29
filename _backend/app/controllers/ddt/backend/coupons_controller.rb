module Ddt
  class Backend::CouponsController < Backend::BaseController
    include ActionView::Helpers::DateHelper
    check_permission :shop, :coupon_version, { [:index, :show] => :show, [:new, :create, :update, :destroy] => :send_coupon}
    before_action :set_coupon, only: [:show, :edit, :update, :destroy]
    layout 'ddt/layouts/backend/coupon_version'

    def index
      is_expired = params[:q].delete(:is_expired) if params[:q]
      case is_expired
      when "1"
        @q = @current_shop.coupons.expired.order(created_at: :desc).ransack(params[:q])
      when "0"
        @q = @current_shop.coupons.not_expired.order(created_at: :desc).ransack(params[:q])
      else
        @q = @current_shop.coupons.order(created_at: :desc).ransack(params[:q])
      end
      @coupons = @q.result.paginate(page: params[:page])
      add_temp_attributes @q, :is_expired
    end

    def show
    end

    def new
      @coupon = @current_shop.coupons.build
    end

    def create
      if params[:send_to_all]
        if coupon_params[:abstract_coupon_version_id].present?
          # 判断是否允许发，一天只能一次
          if @current_shop.last_send_coupon_to_all.present? and @current_shop.last_send_coupon_to_all > 1.days.ago
            words = time_ago_in_words(@current_shop.last_send_coupon_to_all)
            redirect_to [:backend, @current_shop, :coupons], notice: "24小时内只能给全部用户发送一次优惠券，您在#{words}前已经发送过一次"
          else
            @current_shop.update!(:last_send_coupon_to_all => Time.now)
            send_to_all_user
            redirect_to [:backend, @current_shop, @coupon], notice: "发送优惠券的请求已经被接受， 根据用户量的大小，可能需要一定的时间"
          end
        else
          redirect_to [:backend, @current_shop, @coupon], notice: "请先选择优惠券"
        end
      else
        coupons = []
        errors = []
        @coupon_user_ids = params[:coupon][:base_user].split(',')
        Coupon.transaction do
          unless @coupon_user_ids.nil?
            myParams = coupon_params
            @coupon_user_ids.each do |user_id|
              myParams[:base_user_id] = user_id.to_i
              @coupon = @current_shop.coupons.build(myParams)
              @coupon.track_from = :order
              unless @coupon.save
                raise ActiveRecord::Rollback
                errors << @coupon.errors
              else
                coupons << @coupon
              end
            end
          end
        end
        if errors.empty?
          @coupon.update(track_from: :system)
          redirect_to [:backend, @current_shop, @coupon], notice: "#{t('activerecord.models.ddt/coupon')} 创建成功."
        else
          render :new
        end
      end
    end

    def update
      if @coupon.update(coupon_params)
        redirect_to [:backend, @current_shop, @coupon], notice: "#{t('activerecord.models.ddt/coupon')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      @coupon.destroy
      respond_to do |format|
        format.html{
          redirect_to backend_shop_coupons_url(@current_shop), notice: "#{t('activerecord.models.ddt/coupon')} 删除成功."
        }
        format.js
      end
    end

    private

    def send_to_all_user
      Ddt::SendCouponWorker.send_to_all_user(@current_shop.id, coupon_params[:abstract_coupon_version_id])
    end

    def set_coupon
      @coupon = @current_shop.coupons.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(:user_id, :abstract_coupon_version_id, :coupon_no, :track_from, :expires_at, :applied_at, :applied_to_order_id)
    end
  end
end
