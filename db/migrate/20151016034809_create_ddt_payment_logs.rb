class CreateDdtPaymentLogs < ActiveRecord::Migration
  def change
    create_table :ddt_payment_logs do |t|
      t.integer :shop_id
      t.integer :branch_id
      t.integer :order_id
      t.integer :payment_id

      t.string :order_number  # 订单号
      t.string :out_trade_no  # 流水号
      t.decimal :amount, precision: 8, scale: 2       # 金额
      t.string :payment_method_name
      t.string :payment_state
      t.boolean :multi_pay_item         # 组合支付

      t.string :event         # 触发记录日志的事件
      t.text :extra, limit: 65535          # 附加信息

      t.timestamps
    end

    add_index :ddt_payment_logs, :shop_id
    add_index :ddt_payment_logs, :branch_id
    add_index :ddt_payment_logs, :order_id
    add_index :ddt_payment_logs, :payment_id
    add_index :ddt_payment_logs, :order_number
    add_index :ddt_payment_logs, :out_trade_no
    add_index :ddt_payment_logs, :payment_method_name
    add_index :ddt_payment_logs, :payment_state
    add_index :ddt_payment_logs, :created_at

  end
end
