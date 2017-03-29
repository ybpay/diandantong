class AddNoteToPayItem < ActiveRecord::Migration
  def change
    add_column :ddt_pay_items, :note, :string
  end
end
