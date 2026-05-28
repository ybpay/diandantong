module Ddt
  module Api
    module V1
      module Agentsys
        class FeatureModulesConfigsController < BaseController
          before_action :set_shop

          def index
            configs = @shop.feature_modules_configs if @shop
            render json: { data: configs&.map { |c| config_json(c) } || [] }
          end

          def price
            return head :no_content unless params[:feature_module_group].present? && params[:increment_days].present?

            shop = @shop
            return head :no_content unless shop

            original_price = Ddt::FeatureModuleGroup.price_of_charge_version(
              shop,
              shop.expiration_time + params[:increment_days].to_i.days,
              params[:branch_num].to_i,
              params[:feature_module_group]
            )
            price = (original_price * current_agent.discount).round(2)
            left_days_price = Ddt::FeatureModuleGroup.price_of_charge_version(
              shop, shop.expiration_time, params[:branch_num].to_i, params[:feature_module_group]
            ).round(2)
            append_days_price = Ddt::FeatureModuleGroup.amount_of(
              params[:feature_module_group], params[:increment_days].to_i, params[:branch_num].to_i || shop.max_branches_limit
            )

            render json: { price: price, original_price: original_price, append_days_price: append_days_price, left_days_price: left_days_price }
          end

          private

          def set_shop
            @shop = current_agent.shops.find(params[:shop_id]) if params[:shop_id].present?
          rescue ActiveRecord::RecordNotFound
            @shop = nil
          end

          def config_json(config)
            {
              id: config.id,
              feature_module: config.feature_module,
              expired_at: config.expired_at&.to_s,
              active: config.active?
            }
          end
        end
      end
    end
  end
end
