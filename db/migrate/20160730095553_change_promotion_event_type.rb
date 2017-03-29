class ChangePromotionEventType < ActiveRecord::Migration
  def change
    Ddt::PromotionEvent.where(type: "Ddt::Promotion::Events::OrderComplete").update_all(type: "Ddt::Promotion::Events::OrderPay")
  end
end
