class AddHastenToOrderExt < ActiveRecord::Migration
  def change
    add_column :ddt_order_exts, :last_hasten_at, :datetime
  end
end
