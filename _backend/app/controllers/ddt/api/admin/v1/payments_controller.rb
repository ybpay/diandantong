module Ddt
  module Api
    module Admin
      module V1
        class PaymentsController < BaseController
          before_action :set_payment, only: [:show]

          def index
            payments = Ddt::PayItem.joins(order: :branch).where(branches: { shop_id: current_shop.id }).ransack(params[:q]).result
            render_paginated(payments)
          end

          def show
            render_resource(@payment)
          end

          private

          def set_payment
            @payment = Ddt::PayItem.joins(order: :branch).where(branches: { shop_id: current_shop.id }).find(params[:id])
          end
        end
      end
    end
  end
end
