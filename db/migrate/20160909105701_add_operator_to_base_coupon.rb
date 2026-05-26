class AddOperatorToBaseCoupon < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_base_coupons, :operator_id
      add_column :ddt_base_coupons, :operator_id, :integer
    end
    unless column_exists? :ddt_base_coupons, :operator_type
      add_column :ddt_base_coupons, :operator_type, :string
    end
    unless index_exists? :ddt_base_coupons, [:operator_type, :operator_id]
      add_index :ddt_base_coupons, [:operator_type, :operator_id]
    end
    Ddt::BaseCoupon.where("applied_to_order_id IS NOT NULL").find_each do |bc|
      if bc.applied_to_order_id.present?
        order = Ddt::Order.find(bc.applied_to_order_id) rescue nil
        next if order.nil?
        operator_id = nil
        operator_type = nil
        if order.settle_account_id.present?
          operator_id = order.settle_account_id
          operator_type = "Ddt::Account"
        else
          operator_id = bc.base_user_id
          operator_type = "Ddt::BaseUser"
        end
        bc.update(
          applied_in_branch_id: order.branch_id,
          operator_id: operator_id,
          operator_type: operator_type
          )
      end
    end
  end
end
