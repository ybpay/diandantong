class TableStickerCustomeLines < ActiveRecord::Migration
  def change
    add_column :ddt_branches, :table_sticker_custom_line1, :string, default: '微信扫码点餐'
    add_column :ddt_branches, :table_sticker_custom_line2, :string, default: '优惠直达手机'
  end
end
