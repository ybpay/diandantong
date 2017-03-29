# encoding: utf-8
module Ddt
  module BatchChangeOrderState
    extend ActiveSupport::Concern

    included do
    end

    private
    def batch_change_order_state
      new_state = params[:state]
      errors = []
      orders.each do |order|
        error_prefix = "订单#{order.number}, "
        if state_allow_change_to(order, new_state)
          order.ignore_notification = true
          order.send state_to_action(new_state)
          errors << "#{error_prefix}#{order.errors.full_messages}" if order.errors.present?
        else
          errors << "#{error_prefix}不允许更改为#{OrderService::Order::Base.state_name(new_state.to_sym)}"
        end
      end
      yield errors
    end

    def batch_change_order_pay_item_state
      # 现在只支持设置为已支付
      errors = []
      orders.each do |order|
        begin
          order.ignore_notification = true
          order.pay_by_default_method
          errors << "订单#{order.number}, #{order.errors.full_messages}" if order.errors.present?
        rescue => e
          errors << "订单#{order.number}, #{e.message}"
        end
      end
      yield errors
    end

    def orders
      if params[:order] && params[:order][:order_ids]
        @current_shop.orders.accessible_by(current_account).find(params[:order][:order_ids])
      else
        []
      end
    end

    def state_allow_change_to(order, new_state)
      return order.allow_actions.include? state_to_action(new_state)
    end

    def state_to_action(state)
      case state.to_sym
      when :confirmed
        :confirm
      when :completed
        :complete
      when :canceled
        :cancel
      end
    end

  end
end
