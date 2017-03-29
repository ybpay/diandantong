class AddGiftReasonToLineItem < ActiveRecord::Migration
  def change
    add_column :ddt_line_items, :gift_reason, :string
  end
end
