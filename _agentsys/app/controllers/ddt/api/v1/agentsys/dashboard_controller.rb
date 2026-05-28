module Ddt
  module Api
    module V1
      module Agentsys
        class DashboardController < BaseController
          def index
            shops = current_agent.shops.includes(:accounts)
            now = Time.current

            active_count = shops.where(is_give_up: false).where("expiration_time > ?", now).count
            expiring_soon_count = shops.where(is_give_up: false).where(expiration_time: now..30.days.from_now).count
            total_revenue = current_agent.shop_recharge_records.sum(:price).to_f

            recent_shops = shops.order(created_at: :desc).limit(5)
            expiring_shops = shops.where(is_give_up: false)
                                  .where(expiration_time: now..30.days.from_now)
                                  .order(expiration_time: :asc).limit(5)

            render json: {
              stats: {
                totalMerchants: shops.count,
                activeMerchants: active_count,
                totalRevenue: format("%.2f", total_revenue),
                expiringSoon: expiring_soon_count
              },
              recent_merchants: recent_shops.map { |s| shop_json(s) },
              expiring_merchants: expiring_shops.map { |s| shop_json(s).merge(days_left: ((s.expiration_time - now) / 1.day).to_i) }
            }
          end

          private

          def shop_json(shop)
            account = shop.accounts.first
            {
              id: shop.id,
              name: shop.name,
              contact_name: account&.name.to_s,
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
