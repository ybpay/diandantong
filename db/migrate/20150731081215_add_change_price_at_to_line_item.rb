class AddChangePriceAtToLineItem < ActiveRecord::Migration
  def change
    add_column :ddt_line_items, :change_price_at, :datetime
  end
end
