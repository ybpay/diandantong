class AddBanSelfpayToTableZone < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_table_zones, :ban_selfpay
      add_column :ddt_table_zones, :ban_selfpay, :boolean, default: false
    end
  end
end
