class RemoveAdjustableToAdjustment < ActiveRecord::Migration
  def up
    Ddt::Adjustment.where(adjustable_type: 'Ddt::Shipment').delete_all if column_exists? :ddt_adjustments, :adjustable_type
    Ddt::Adjustment.where(source_type: 'Ddt::PromotionAction', eligible: false).delete_all
    if column_exists? :ddt_adjustments, :adjustable_type
      remove_index :ddt_adjustments, column: [:adjustable_type, :adjustable_id], name: "index_ddt_adjustments_on_adjustable", using: :btree
      remove_column :ddt_adjustments, :adjustable_type, :string
      remove_column :ddt_adjustments, :adjustable_id, :integer
      add_column :ddt_adjustments, :reason, :string
    end
    Ddt::Adjustment.where(source_type: "Ddt::PromotionAction").update_all(reason: :promotion)
    Ddt::Adjustment.where(source_type: "Ddt::TableZone").update_all(reason: :reservation_table_price)
    execute <<-SQL
      UPDATE ddt_adjustments a
      LEFT JOIN ddt_base_coupons c ON a.source_id = c.id
      SET a.reason = "coupon"
      where a.source_type = "Ddt::BaseCoupon" and c.type = "Ddt::Coupon";
    SQL
    execute <<-SQL
      UPDATE ddt_adjustments a
      LEFT JOIN ddt_base_coupons c ON a.source_id = c.id
      SET a.reason = "voucher"
      where a.source_type = "Ddt::BaseCoupon" and c.type = "Ddt::Voucher";
    SQL
    Ddt::Adjustment.where(label: "积分抵扣").update_all(reason: :credits_deduction)
    Ddt::Adjustment.where(label: "余额抵扣").update_all(reason: :card_deduction)
    Ddt::Adjustment.where(label: "权限折扣").update_all(reason: :privilege_discount)
    Ddt::Adjustment.where(label: "权限减免").update_all(reason: :privilege_reduction)
    Ddt::Adjustment.where(label: "权限免单").update_all(reason: :privilege_free)
    Ddt::Adjustment.where(label: "抹零").update_all(reason: :moling)
    Ddt::Adjustment.where(label: "买单金额").update_all(reason: :payment_price)
    Ddt::Adjustment.where(label: "订座预付").update_all(reason: :prepay_for_reservation_table)
    Ddt::Adjustment.where(label: "预订预付").update_all(reason: :prepay_for_reservation_order)
    Ddt::Adjustment.where(reason: nil).update_all(reason: :other)
  end

  def down
    remove_column :ddt_adjustments, :reason, :string
    add_column :ddt_adjustments, :adjustable_id, :integer
    add_column :ddt_adjustments, :adjustable_type, :string
    add_index :ddt_adjustments, [:adjustable_type, :adjustable_id], name: "index_ddt_adjustments_on_adjustable", using: :btree
  end
end
