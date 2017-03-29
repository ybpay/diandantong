class AddPositionToReason < ActiveRecord::Migration
  def change
    add_column :ddt_gift_reasons, :position, :integer unless column_exists? :ddt_gift_reasons, :position
    add_column :ddt_subtract_reasons, :position, :integer unless column_exists? :ddt_subtract_reasons, :position
    add_column :ddt_item_notes, :position, :integer unless column_exists? :ddt_item_notes, :position
    Ddt::Shop.all.find_each do |shop|
      shop.gift_reasons.each_with_index do |reason, index|
        reason.update_column(:position, index + 1)
      end
      shop.subtract_reasons.each_with_index do |reason, index|
        reason.update_column(:position, index + 1)
      end
    end
    Ddt::Branch.all.find_each do |branch|
      branch.item_notes.each_with_index do |item_note, index|
        item_note.update_column(:position, index + 1)
      end
    end
  end
end
