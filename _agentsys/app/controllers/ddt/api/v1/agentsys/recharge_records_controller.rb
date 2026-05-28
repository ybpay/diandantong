module Ddt
  module Api
    module V1
      module Agentsys
        class RechargeRecordsController < BaseController
          before_action :set_shop, only: [:index, :create]

          def index
            records = if @shop
              @shop.shop_recharge_records.where(agent: current_agent)
            else
              current_agent.shop_recharge_records
            end
            records = records.order(created_at: :desc)
            records = records.ransack(params[:q]).result(distinct: true) if params[:q].present?
            render_paginated(records)
          end

          def show
            record = current_agent.shop_recharge_records.find(params[:id])
            render_resource(record)
          end

          def create
            unless @shop
              render json: { errors: [{ status: 400, title: "缺少shop_id参数", code: "PARAMETER_MISSING" }] }, status: :bad_request
              return
            end

            record = @shop.shop_recharge_records.build(
              increment_days: params[:increment_days].to_i,
              recharge_type: params[:recharge_type] || @shop.shop_type,
              branch_num: @shop.max_branches_limit,
              agent: current_agent,
              note: params[:note]
            )
            record.beginning_time = [Time.current, @shop.expiration_time].max
            record.ending_time = record.beginning_time + record.increment_days.days
            record.original_price = Ddt::FeatureModuleGroup.price_of_charge_version(@shop, record.ending_time, record.branch_num, record.recharge_type)
            record.price = (record.original_price * current_agent.discount).round(2)

            if record.save
              render_resource_created(record)
            else
              render_errors(record.errors)
            end
          end

          private

          def set_shop
            @shop = current_agent.shops.find(params[:shop_id]) if params[:shop_id].present?
          end
        end
      end
    end
  end
end
