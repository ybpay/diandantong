module Ddt
  module Api
    module V1
      module Agentsys
        class RechargeRecordsController < Ddt::Api::V1::BaseController
          def index
            records = Ddt::ShopRechargeRecord.where(shop: current_account.agent_shops)
                         .ransack(params[:q]).result
            render_paginated(records)
          end

          def create
            shop = current_account.agent_shops.find(params[:shop_id])
            record = shop.recharge_records.build(record_params.merge(operator: current_account))
            if record.save
              render_resource_created(record)
            else
              render_errors(record.errors)
            end
          end

          private

          def record_params
            params.require(:recharge_record).permit(:amount, :note, :recharge_type)
          end
        end
      end
    end
  end
end
