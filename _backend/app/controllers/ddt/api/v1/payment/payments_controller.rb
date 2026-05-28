module Ddt
  module Api
    module V1
      module Backend
        class PaymentsController < Ddt::Api::V1::BaseController
          before_action :set_shop
          before_action :set_payment, only: [:show, :refund]

          def index
            branch_ids = current_account.managed_branch_ids
            branch_ids << current_shop.abstract_branch.id if current_account.is_boss?
            payments = current_shop.payments.with_discarded
                        .where(branch_id: branch_ids)
                        .order(created_at: :desc)
            payments = apply_order_search(payments)
            render_paginated(payments)
          end

          def show
            render_resource(@payment)
          end

          def refund
            unless @payment.may_refund?
              return render_errors({ base: "当前支付状态不允许退款" }, :bad_request)
            end

            result = @payment.refund(refund_params)
            if result
              render_resource(@payment)
            else
              render_errors({ base: "退款失败" }, :unprocessable_entity)
            end
          end

          def statistics
            branch_ids = current_account.managed_branch_ids
            branch_ids << current_shop.abstract_branch.id if current_account.is_boss?
            payments = current_shop.payments.completed
                        .where(branch_id: branch_ids)
            payments = payments.where(created_at: time_range) if params[:start_time].present?

            render json: {
              data: {
                total_amount: payments.sum(:amount),
                count: payments.count,
                by_method: payments.group(:payment_method_id).sum(:amount),
                by_state: current_shop.payments.with_discarded
                            .where(branch_id: branch_ids)
                            .group(:workflow_state).count,
                time_range: time_range_params
              }
            }
          end

          private

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end

          def set_payment
            @payment = current_shop.payments.find(params[:id])
          end

          def apply_order_search(payments)
            if params[:q].present?
              if params[:q][:order_id_eq].present?
                order = current_shop.orders.find_by(number: params[:q][:order_id_eq])
                params[:q][:order_id_eq] = order.id if order.present?
              end
              payments.ransack(params[:q]).result
            else
              payments
            end
          end

          def refund_params
            params.fetch(:refund, {}).permit(:amount, :reason)
          end

          def time_range
            @time_range ||= begin
              start_time = params[:start_time] ? Time.parse(params[:start_time]) : 30.days.ago.beginning_of_day
              end_time = params[:end_time] ? Time.parse(params[:end_time]) : Time.current
              start_time..end_time
            end
          end

          def time_range_params
            { start: time_range.begin, end: time_range.end }
          end
        end
      end
    end
  end
end
