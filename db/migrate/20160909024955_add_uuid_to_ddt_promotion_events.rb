class AddUuidToDdtPromotionEvents < ActiveRecord::Migration
  def change
    add_column :ddt_promotion_events, :uuid, :string
    add_index :ddt_promotion_events, :uuid
  end
end
