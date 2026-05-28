module Ddt
  module Api
    module V1
      module Backend
        class ShopsController < Ddt::Api::V1::BaseController
          before_action :set_shop

          def show
            render_resource(@shop)
          end

          def update
            unless current_account.is_admin? || current_account.is_boss?
              return render_errors({ base: "无权修改店铺信息" }, :forbidden)
            end

            if @shop.update(shop_params)
              render_resource(@shop)
            else
              render_errors(@shop.errors)
            end
          end

          def feature_modules
            render json: { data: @shop.feature_modules_configs.available.map(&:as_api_json) }
          end

          def branches_summary
            branches = @shop.branches.real
            render json: {
              data: {
                total: branches.count,
                active: branches.where(is_in_service: true).count,
                inactive: branches.where(is_in_service: false).count,
                branches: branches.map { |b| { id: b.id, name: b.name, is_in_service: b.is_in_service? } }
              }
            }
          end

          private

          def set_shop
            if params[:id].present? || params[:shop_slug].present?
              @shop = current_account.is_admin? ? Ddt::Shop.friendly.find(params[:id] || params[:shop_slug]) : current_account.shop
            else
              @shop = current_account.shop
            end
          end

          def shop_params
            permitted = if current_account.is_admin?
              [:name, :slug, :is_open, :expiration_time, :telephone, :service_email, :sina_weibo,
                :introduction, :image, :rect_image, :charge_method, :use_custom_brand, :is_ban,
                :agent_no, :custom_brand_name, :custom_brand_link, :hide_support_brand,
                :enable_foreign, :foreign_currency_symbol, :foreign_time_zone, :vip_logo,
                :shop_type, :max_branches_limit, :search_words, :custom_domain, :sale_employee_id]
            else
              [:name, :telephone, :service_email, :sina_weibo,
                :introduction, :image, :rect_image, :enable_foreign, :foreign_currency_symbol,
                :foreign_time_zone, :vip_logo, :search_words, :sale_employee_id]
            end
            params.require(:shop).permit(permitted)
          end
        end
      end
    end
  end
end
