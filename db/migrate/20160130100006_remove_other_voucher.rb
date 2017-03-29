class RemoveOtherVoucher < ActiveRecord::Migration
  def up
    Ddt::Adjustment.where(source_type: 'Ddt::OtherVoucher').delete_all
    drop_table :ddt_other_vouchers
  end

  def down
  end
end
