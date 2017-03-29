class FixLineItemGift < ActiveRecord::Migration
  def change
    Ddt::LineItem.where(gift: nil).update_all(gift: false)
  end
end
