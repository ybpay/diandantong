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
            authorize! record, with: Ddt::Agentsys::RechargeRecordPolicy
            render_resource(record)
          end

          def create
            unless @shop
              render json: { errors: [{ status: 400, title: "缺少shop_id参数", code: "PARAMETER_MISSING" }] }, status: :bad_request
              return
            end

            recharge_type = (params[:recharge_type] || @shop.shop_type).to_sym

            if recharge_type == :base && !current_agent.is_hardware_level?
              render json: { errors: [{ status: 403, title: "不允许的续费类型，仅硬件渠道商可为base类型充值", code: "FORBIDDEN" }] }, status: :forbidden
              return
            end

            record = @shop.shop_recharge_records.build(
              increment_days: params[:increment_days].to_i,
              recharge_type: recharge_type,
              branch_num: @shop.max_branches_limit,
              agent: current_agent,
              note: params[:note]
            )
            record.beginning_time = [Time.current, @shop.expiration_time].max
            record.ending_time = record.beginning_time + record.increment_days.days

            max_agent_to = current_agent.agent_rels.maximum(:agent_to)
            if record.increment_days > 0 && @shop.expiration_time > max_agent_to
              render json: { errors: [{ status: 403, title: "您的代理期限到#{max_agent_to.to_date}截止，不能为超出代理期限的客户充值", code: "AGENT_EXPIRATION_EXCEEDED" }] }, status: :forbidden
              return
            end

            record.original_price = Ddt::FeatureModuleGroup.price_of_charge_version(@shop, record.ending_time, record.branch_num, record.recharge_type)
            record.price = (record.original_price * current_agent.discount).round(2)

            authorize! record, with: Ddt::Agentsys::RechargeRecordPolicy
            if record.save
              render_resource_created(record)
            else
              render_errors(record.errors)
            end
          end

          def create_free
            shop = current_agent.shops.includes(:feature_modules_configs).find(params[:shop_id])

            unless shop.can_recharge_free?
              render json: { errors: [{ status: 403, title: "该帐号试用时间超过一个月，不允许再继续免费试用", code: "FREE_TRIAL_NOT_ALLOWED" }] }, status: :forbidden
              return
            end

            max_days = (shop.max_recharge_free_time / 3600 / 24 - 1)
            increment_days = params[:increment_days].to_i

            if increment_days > max_days
              render json: { errors: [{ status: 403, title: "延长时间超过了允许的范围", code: "FREE_TRIAL_DAYS_EXCEEDED" }] }, status: :forbidden
              return
            end

            record = shop.shop_recharge_records.build(
              increment_days: increment_days,
              recharge_type: :base,
              branch_num: shop.max_branches_limit,
              agent: current_agent
            )
            record.beginning_time = [Time.current, shop.expiration_time].max
            record.ending_time = record.beginning_time + increment_days.days
            record.price = 0
            record.original_price = 0

            ActiveRecord::Base.transaction do
              record.save!
              Ddt::FeatureModuleGroup.send(:trial)[:modules].each do |fm|
                config = shop.feature_modules_configs.find_by(feature_module: fm)
                if config
                  config.update!(expired_at: [config.expired_at, record.ending_time].max)
                end
              end
            end

            render json: { data: { message: "成功延长试用#{increment_days}天", expires_at: record.ending_time.to_s } }, status: :created
          rescue ActiveRecord::RecordNotFound
            render json: { errors: [{ status: 404, title: "商户不存在", code: "NOT_FOUND" }] }, status: :not_found
          rescue => e
            render json: { errors: [{ status: 422, title: "免费试用延期失败", detail: e.message, code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
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
