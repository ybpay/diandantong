class AddScanCodeToVipInfo < ActiveRecord::Migration
  def change
    add_column :ddt_vip_infos, :scan_code, :string
    add_column :ddt_vip_infos, :updated_scan_code_at, :datetime
  end
end
