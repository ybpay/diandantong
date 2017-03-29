class UpdateShift < ActiveRecord::Migration
  def change
    remove_column :ddt_shifts, :initial_amount, precision: 8, scale: 2 if column_exists? :ddt_shifts, :initial_amount
    remove_column :ddt_shifts, :turnover_amount, precision: 8, scale: 2 if column_exists? :ddt_shifts, :turnover_amount
    remove_column :ddt_shifts, :final_amount, precision: 8, scale: 2 if column_exists? :ddt_shifts, :final_amount
    remove_column :ddt_shifts, :alipay_amount, precision: 8, scale: 2 if column_exists? :ddt_shifts, :alipay_amount
    remove_column :ddt_shifts, :wechatpay_amount, precision: 8, scale: 2 if column_exists? :ddt_shifts, :wechatpay_amount
    remove_column :ddt_shifts, :baidupay_amount, precision: 8, scale: 2 if column_exists? :ddt_shifts, :baidupay_amount
    remove_column :ddt_shifts, :vip_card_pay_amount, precision: 8, scale: 2 if column_exists? :ddt_shifts, :vip_card_pay_amount
    remove_column :ddt_shifts, :bank_card_pay_amount, precision: 8, scale: 2 if column_exists? :ddt_shifts, :bank_card_pay_amount
    #total_amount
    add_column :ddt_shifts, :total_actual_amount, :decimal, precision: 8, scale: 2 unless column_exists? :ddt_shifts, :total_actual_amount
    add_column :ddt_shifts, :recharge_amount, :decimal, precision: 8, scale: 2 unless column_exists? :ddt_shifts, :recharge_amount

    create_table :ddt_shift_items do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.references :shift, index: true
      t.references :pay_method, index: true
      t.string :pay_method_name
      t.string :pay_method_code
      t.boolean :pay_method_is_actual
      t.decimal :amount, precision: 8, scale: 2
      t.timestamps
    end unless table_exists? :ddt_shift_items

    index = 0
    total_index = Ddt::Shift.closed.count
    Ddt::Shift.closed.find_each do |shift|
      puts "start to migrate for shift #{shift.id} of branch #{shift.branch_id}"
      base_hash = Hash[shift.shop.pay_methods.enable.pluck(:id).map{|id| [id, 0]}]
      branch = Ddt::Branch.with_deleted.find(shift.branch_id)
      result_hash = branch.pay_items.paid.includes(:pay_method).where(paid_at: shift.created_at..shift.closed_at, ddt_pay_methods: { enable: true }).references(:ddt_pay_methods).group('ddt_pay_methods.id').sum("ddt_pay_items.amount")
      final_hash = base_hash.merge(result_hash)
      Ddt::ShiftItem.transaction do
        final_hash.each do |id, amount|
          shift_item = shift.shift_items.build(pay_method_id: id, amount: amount, branch_id: shift.branch_id, shop_id: shift.shop_id)
          shift_item.save(validate: false)
          shift_item.update_columns(branch_id: shift.branch_id, shop_id: shift.shop_id)
        end
        shift.total_amount = shift.shift_items.sum(:amount)
        shift.total_actual_amount = shift.shift_items.where(pay_method_is_actual: true).sum(:amount)
        shift.recharge_amount = -branch.card_wallet.wallet_logs.where(created_at: shift.created_at..shift.closed_at, reason: :for_recharge).sum(:cash_amount)
        if shift.branch.nil?
          shift.save(validate: false)
        else
          shift.save!
        end
      end
      puts "create shift item index : #{index}/#{total_index}" if index % 100 == 0
      index += 1
    end
  end
end
