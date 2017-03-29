class AddShowNoteInWeixinToProduct < ActiveRecord::Migration
  def change
    add_column :ddt_products, :show_note_in_weixin, :boolean, default: false
  end
end
