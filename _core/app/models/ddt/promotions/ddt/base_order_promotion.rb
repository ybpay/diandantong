module Ddt
  class BaseOrderPromotion < Ddt::Promotion
    def usage_limit_exceeded?(promotable)
      usage_limit.present? && usage_limit > 0 && adjusted_usage_count(promotable) >= usage_limit
    end

    def adjusted_usage_count(promotable)
      promotable.promotion_ids.include?(self.id) ? usage_count - 1 : usage_count
    end

    def usage_count
      order_ids.count
    end

    def activate(promotable)
      actions.map do |action|
        action.perform(promotable)
      end
    end

    def used_by?(user, options = {})
      excluded_orders = options[:excluded_orders] || []
      OrderService::Orders.where(id: order_ids - excluded_orders.map(&:id), base_user_id: user.id).count > 0
    end

    def order_ids
      sql = "select order_id from ddt_promotions_orders where promotion_id = #{self.id};"
      @order_ids ||= ActiveRecord::Base.connection.execute(sql).to_a.map{|a|a[0]}
    end
  end
end