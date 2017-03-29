module Ddt
  class PromotionEvent < Ddt::Base
    include Ddt::BelongsToShop
    has_and_belongs_to_many :promotions, join_table: 'ddt_promotions_promotion_events', class_name: 'Ddt::Promotion'

    belongs_to :user, class_name: 'Ddt::BaseUser', foreign_key: :base_user_id
    belongs_to :wechat_share_record, class_name: 'Ddt::WechatShareRecord'
    scope :today,          -> { where("ddt_promotion_events.created_at BETWEEN '#{DateTime.now.beginning_of_day}' AND '#{DateTime.now.end_of_day}'") }
    scope :of_type,        ->(type){ where(type: type)}
    scope :order_pay, -> { where(type: 'Ddt::Promotion::Events::OrderPay')}
    scope :user_follow,    -> { where(type: 'Ddt::Promotion::Events::UserFollow')}
    scope :user_sign_in,   -> { where(type: 'Ddt::Promotion::Events::UserSignIn')}
    scope :user_active_vip,-> { where(type: 'Ddt::Promotion::Events::UserActiveVip')}
    scope :vip_birthday,   -> { where(type: 'Ddt::Promotion::Events::VipBirthday')}
    scope :share_to_friend_circle, -> {where(type: 'Ddt::Promotion::Events::ShareToFriendCircle')}

    set_from :user

    after_create :handle_promotion
    private
    def handle_promotion
      if self.type == "Ddt::Promotion::Events::OrderPay"
        pending_promotions = self.shop.event_promotions.active.active_in_branch(self.order.branch).load
        # pending_promotions += self.order.branch.event_promotions.active.load
      else
        pending_promotions = self.shop.event_promotions.active.load
      end
      pending_promotions.each do |promotion|
        promotion.activate(self) if promotion.eligible?(self)
      end
    end

    
    
  end
end
