# encoding: utf-8
module Ddt
  class Backend::Admin::ShopRechargeRecordsController < Backend::BaseAdminController
    before_action :set_shop_recharge_record, only: [:edit, :update]
    before_action :set_shop_recharge_records, only: [:index]


    def index
      @q = @shop_recharge_records.order(created_at: :desc).ransack(params[:q])
      @shop_recharge_records = @q.result(distinct: true).paginate(page: params[:page])
    end

    def new
        @shop_recharge_record = @current_shop.shop_recharge_records.build
        @shop_recharge_record.recharge_type = @current_shop.shop_type
        if params[:feature_module_group].present? && Ddt::FeatureModuleGroup.all.include?(params[:feature_module_group].to_sym)
          @shop_recharge_record.recharge_type = params[:feature_module_group]
        end
        if params[:feature_module_group].present?
          @shop_recharge_record.increment_days = 365
        end
        @shop_recharge_record.branch_num = @current_shop.max_branches_limit
        @shop_recharge_record.beginning_time = @current_shop.expiration_time
        @shop_recharge_record.ending_time = @current_shop.expiration_time
        if @shop_recharge_record.increment_days.present?
          @shop_recharge_record.ending_time = @current_shop.expiration_time + @shop_recharge_record.increment_days.days
        end
        @shop_recharge_record.price = Ddt::FeatureModuleGroup.price_of_charge_version(@current_shop, @shop_recharge_record.ending_time, @current_shop.max_branches_limit, @shop_recharge_record.recharge_type)
    end

    def create
      @shop_recharge_record = @current_shop.shop_recharge_records.build(shop_recharge_record_params)
      if @shop_recharge_record.save
        redirect_to backend_shop_shop_recharge_records_path(@current_shop), notice: "创建成功"
      else
        render 'new'
      end
    end

    def edit
    end

    def update
      if @shop_recharge_record.update(shop_recharge_record_params)
        redirect_to backend_shop_shop_recharge_records_path(@current_shop), notice: "更新成功"
      else
        render action: 'edit'
      end
    end

    private
    def set_shop_recharge_record
      @shop_recharge_record = @current_shop.shop_recharge_records.find(params[:id])
    end

    def set_shop_recharge_records

      if @current_shop.present?
        @shop_recharge_records = @current_shop.shop_recharge_records
      else
        @shop_recharge_records = ShopRechargeRecord.all
      end

      recharge_by = params[:recharge_by]
      if params[:recharge_by].present?
        if recharge_by == "admin"
          @shop_recharge_records = @shop_recharge_records.where("agent_id IS NULL")
        elsif recharge_by == "agent"
          @shop_recharge_records = @shop_recharge_records.where("agent_id IS NOT NULL")
        end
      end
    end

    def shop_recharge_record_params
      params.require(:shop_recharge_record).permit(:price, :recharge_type, :increment_days, :note, :branch_num)
    end
  end
end
