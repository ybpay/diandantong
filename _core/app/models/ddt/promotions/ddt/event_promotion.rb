module Ddt
  class EventPromotion < Ddt::Promotion
    has_and_belongs_to_many :promotion_events, join_table: 'ddt_promotions_promotion_events', class_name: 'Ddt::PromotionEvent', foreign_key: :promotion_id

    def usage_limit_exceeded?(promotable)
      usage_limit.present? && usage_limit > 0 && usage_count >= usage_limit
    end

    def usage_count
      self.promotion_events.count
    end

    def activate(promotable)
      promotion_event = promotable
      actions.each do |action|
        action.perform(promotion_event)
      end
      self.promotion_events << promotion_event 
    end
  end
end