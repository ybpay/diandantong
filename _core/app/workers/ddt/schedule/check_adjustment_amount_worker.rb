module Ddt
  module Schedule
    class CheckAdjustmentAmountWorker < Ddt::Schedule::Base
      def perform
        now = Time.now
        start_time = Time.now.beginning_of_day
        end_time = now.end_of_day
        interval = start_time..end_time
        errors = []
        Ddt::Order.where(
          placed_at: interval,
          pay_item_state: :paid,
          type: ["Ddt::EatInHallOrder", "Ddt::DeliveryOrder", "Ddt::FastfoodOrder"]
        ).pluck(:id).each_slice(200).to_a.each do |ids|
          puts "start to check order id of #{ids}"
          Ddt::OrderService::Order::Base.where(id: ids).each do |order|
            if order.pay_items.map(&:amount).sum.round(2) != order.total
              error = "Error 1======== branch_id: #{order.branch_id}, order_id: #{order.id}, number: #{order.number}, total: #{order.total.to_f}, pay_items_amount: #{order.pay_items.map(&:amount).sum.round(2)}  ============="
              if error.present?
                errors << error
                puts error
              end
            end

            line_items_adjustment_amount = order.line_items.active.map{|l| l.adjustment_total + l.apportion_adjustment_total}.sum.to_f.round(2)
            line_items_not_actual_amount = order.line_items.active.map(&:not_actual_amount).sum.to_f.round(2)
            pay_items_not_actual_amount = order.pay_items.map(&:get_not_actual_amount).sum.to_f.round(2)
            if order.adjustment_total.to_f != line_items_adjustment_amount || line_items_not_actual_amount != pay_items_not_actual_amount
              error = "Error 2======== branch_id: #{order.branch_id}, order_id: #{order.id}, number: #{order.number}, adjustment_total: #{order.adjustment_total.to_f}, line_items_adjustment_amount: #{line_items_adjustment_amount}, line_items_not_actual_amount: #{line_items_not_actual_amount}, pay_items_not_actual_amount: #{pay_items_not_actual_amount} ============="
              if error.present?
                errors << error
                puts error
              end
            end
            query = {is_async: false, shop: order.shop, branch_id: order.branch_id, start_time: start_time, end_time: end_time}
            error = compare_order(query, order)
            if error.present?
              errors << error
              puts error
            end

            vip_card_pay_pay_items = order.pay_items.select(&:vip_card_pay?)
            pay_item_vip_pay_amount            = 0
            pay_item_vip_pay_actual_amount     = 0
            pay_item_vip_pay_not_actual_amount = 0

            if vip_card_pay_pay_items.length > 0
              vip_card_pay_pay_items.each do |pay_item|
                pay_item_vip_pay_amount            += pay_item.amount
                pay_item_vip_pay_actual_amount     += pay_item.actual_amount
                pay_item_vip_pay_not_actual_amount += pay_item.get_not_actual_amount
              end
            end
            logs = order.branch.card_wallet.wallet_logs.where(reason: [:for_vip_card_pay, :for_rollback_vip_card_pay], order_id: order.id)
            wallet_log_vip_pay_amount       = logs.sum(:amount)
            wallet_log_vip_pay_cash_amount  = logs.sum(:cash_amount)
            wallet_log_vip_pay_extra_amount = logs.sum(:extra_amount)
            if pay_item_vip_pay_amount != wallet_log_vip_pay_amount ||
                pay_item_vip_pay_actual_amount != wallet_log_vip_pay_cash_amount ||
                pay_item_vip_pay_not_actual_amount != wallet_log_vip_pay_extra_amount
              error = "Error vip card======== branch_id: #{order.branch_id}, order_id: #{order.id}, number: #{order.number}, [#{pay_item_vip_pay_amount.to_f}, #{pay_item_vip_pay_actual_amount.to_f}, #{pay_item_vip_pay_not_actual_amount.to_f}] [#{wallet_log_vip_pay_amount.to_f}, #{wallet_log_vip_pay_extra_amount.to_f}, #{wallet_log_vip_pay_cash_amount.to_f}]  ============="
              errors << error
              puts error
            end
          end
        end
        errors = errors.compact
        puts errors.join("\n")
        if errors.present? && Rails.env.production?
          BaseMailer.notify(
            Rails.application.config.dev_mail_group,
            "[adjustment_amount_check]",
            errors.join("\n")
          )
        end
      end


      def compare_order(query, order)
        product_statistic = Ddt::ProductStatistic::ProductSummary.new(query.merge({order_id: order.id}))
        product_statistic_foot = product_statistic.foot[1]
        product_statistic_discount = product_statistic_foot[-5]
        product_statistic_amount = product_statistic_foot[-4]
        product_statistic_not_actual_amount = product_statistic_foot[-3]
        product_statistic_actual_amount = product_statistic_foot[-2]
        product_statistic_original_amount = product_statistic_foot[-6]

        if product_statistic_amount != order.total
          return "Error 3: {branch_id: #{query[:branch_id]}, type: #{order.type}, order_id: #{order.id}, number: #{order.number}, st: #{product_statistic_amount}, total: #{order.total}, discount: #{product_statistic_discount}},"
        end

        order_discount = order.line_items.select{|l| !l.is_subtract && !l.is_moved && (l.quantity - l.subtract_quantity > 0)}.map{|l| l.adjustment_total + l.apportion_adjustment_total}.sum.to_f.round(2)
        product_discount = product_statistic_discount.to_f.round(2)
        if product_discount != order_discount + order.moling_amount
          return "Error 4: {branch_id: #{query[:branch_id]}, type: #{order.type}, order_id: #{order.id}, number: #{order.number}, st: #{product_discount}, order_discount: #{order_discount + order.moling_amount}}"
        end

        order_no_actual_amount = order.line_items.select{|l| !l.is_subtract && !l.is_moved && (l.quantity - l.subtract_quantity > 0)}.map{|l| l.not_actual_amount }.sum.to_f.round(2)
        if order_no_actual_amount != product_statistic_not_actual_amount.to_f.round(2)
          return "Error 5: {branch_id: #{query[:branch_id]}, type: #{order.type}, order_id: #{order.id}, number: #{order.number}, st: #{product_statistic_not_actual_amount}, order_no_actual_amount: #{order_no_actual_amount}}"
        end
        nil
      end
    end
  end
end
