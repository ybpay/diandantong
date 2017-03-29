class AddVipNoIndex < ActiveRecord::Migration
  def change
    add_index :ddt_vip_infos, :vip_no, :length => {:vip_no => 191}
  end
end
