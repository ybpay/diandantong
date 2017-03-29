class RemoveLineItemPromotion < ActiveRecord::Migration
  def up
    drop_table :ddt_promotions_line_items if table_exists? :ddt_promotions_line_items
    pids = Ddt::Promotion.where(type: "Ddt::LineItemPromotion").pluck(:id)
    Ddt::PromotionRule.where(promotion_id: pids).delete_all
    Ddt::PromotionAction.where(promotion_id: pids).delete_all
    Ddt::Promotion.where(type: "Ddt::LineItemPromotion").delete_all
  end

  def down
  end
end
