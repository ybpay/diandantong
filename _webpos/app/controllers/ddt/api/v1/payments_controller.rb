module Ddt
  module Api
    module V1
      module Webpos
        class PaymentsController < Ddt::Api::V1::BaseController
          before_action :set_branch
          before_action :set_order, only: [:create]

          def create
            pay_item = @order.pay_items.build(pay_item_params)
            if pay_item.save
              render_resource_created(pay_item)
            else
              render_errors(pay_item.errors)
            end
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def set_order
            @order = @branch.orders.find(params[:order_id])
          end

          def pay_item_params
            params.require(:pay_item).permit(:amount, :pay_method, :note)
          end
        end
      end
    end
  end
end
