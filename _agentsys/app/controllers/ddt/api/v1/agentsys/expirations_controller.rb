module Ddt
  module Api
    module V1
      module Agentsys
        class ExpirationsController < BaseController
          def index
            shops = current_agent.shops.includes(:accounts).where(is_give_up: false)
            shops = apply_filters(shops)
            all_shops = shops.order(expiration_time: :asc)

            expired = shops.where("expiration_time < ?", Time.current).count
            expiring_7 = shops.where(expiration_time: Time.current..7.days.from_now).count
            expiring_30 = shops.where(expiration_time: Time.current..30.days.from_now).count

            items = paginate_collection(all_shops)

            render json: {
              merchants: items.map { |s| expiration_json(s) },
              total: all_shops.count,
              summary: {
                expired: expired,
                expiring7Days: expiring_7,
                expiring30Days: expiring_30
              }
            }
          end

          private

          def apply_filters(shops)
            result = shops
            case params[:filter]
            when "expired"
              result = result.where("expiration_time < ?", Time.current)
            when "7days"
              result = result.where(expiration_time: Time.current..7.days.from_now)
            when "30days"
              result = result.where(expiration_time: Time.current..30.days.from_now)
            end
            if params[:keyword].present?
              kw = "%#{params[:keyword]}%"
              result = result.where("name ILIKE ?", kw)
            end
            result
          end

          def expiration_json(shop)
            account = shop.accounts.first
            days_left = shop.expiration_time ? ((shop.expiration_time - Time.current) / 1.day).to_i : 0
            {
              id: shop.id,
              name: shop.name,
              contact_name: account&.name.to_s,
              phone: shop.phone.to_s,
              plan_name: shop.shop_type.to_s,
              expires_at: shop.expiration_time&.to_s,
              days_left: days_left
            }
          end
        end
      end
    end
  end
end
