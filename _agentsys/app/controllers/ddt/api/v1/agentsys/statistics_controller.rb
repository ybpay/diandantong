module Ddt
  module Api
    module V1
      module Agentsys
        class StatisticsController < BaseController
          def index
            start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 30.days.ago.to_date
            end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current

            shops = current_agent.shops
            records = current_agent.shop_recharge_records.where(created_at: start_date..end_date.end_of_day)

            new_merchants = shops.where(created_at: start_date..end_date.end_of_day).count
            total_revenue = records.sum(:price).to_f
            renew_count = records.count
            active_merchants = shops.where(is_give_up: false).where("expiration_time > ?", Time.current).count

            commissions = records.order(created_at: :desc).limit(50).map do |r|
              {
                merchant_name: r.shop&.name.to_s,
                order_amount: format("%.2f", r.original_price.to_f),
                commission_rate: "#{(current_agent.discount * 100).round(1)}%",
                commission_amount: format("%.2f", r.price.to_f),
                created_at: r.created_at.to_s
              }
            end

            render json: {
              summary: {
                newMerchants: new_merchants,
                totalRevenue: format("%.2f", total_revenue),
                renewCount: renew_count,
                activeMerchants: active_merchants
              },
              commissions: commissions
            }
          end
        end
      end
    end
  end
end
