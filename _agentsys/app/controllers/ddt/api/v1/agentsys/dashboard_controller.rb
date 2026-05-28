module Ddt
  module Api
    module V1
      module Agentsys
        class DashboardController < BaseController
          def index
            shops = current_agent.shops
            active = shops.select { |s| !s.is_give_up && s.expiration_time > Time.current }
            expiring_soon = shops.select { |s| !s.is_give_up && s.expiration_time > Time.current && s.expiration_time < 30.days.from_now }
            total_revenue = current_agent.shop_recharge_records.sum(:price).to_f

            recent_shops = shops.order(created_at: :desc).limit(5)

            render json: {
              stats: {
                totalMerchants: shops.count,
                activeMerchants: active.size,
                totalRevenue: format("%.2f", total_revenue),
                expiringSoon: expiring_soon.size
              },
              recent_merchants: recent_shops.map { |s| shop_json(s) },
              expiring_merchants: expiring_soon.first(5).map { |s| shop_json(s).merge(days_left: ((s.expiration_time - Time.current) / 1.day).to_i) }
            }
          end

          private

          def shop_json(shop)
            {
              id: shop.id,
              name: shop.name,
              contact_name: shop.accounts.first&.name.to_s,
              phone: shop.phone.to_s,
              status: shop_status(shop),
              status_label: shop_status_label(shop),
              expires_at: shop.expiration_time&.to_s,
              created_at: shop.created_at.to_s
            }
          end

          def shop_status(shop)
            return "suspended" if shop.is_give_up?
            return "expired" if shop.expiration_time && shop.expiration_time < Time.current
            "active"
          end

          def shop_status_label(shop)
            case shop_status(shop)
            when "suspended" then "已停用"
            when "expired" then "已过期"
            else "活跃"
            end
          end
        end
      end
    end
  end
end
