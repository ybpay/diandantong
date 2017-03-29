#encoding:utf-8
class PayMethodChange < ActiveRecord::Migration
  def up
    create_table :ddt_pay_items do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.references :order, index: true
      t.references :pay_method, index: true
      t.references :payment, index: true
      t.decimal :amount, precision: 8, scale: 2
      t.string :state, default: 'unpaid'
      t.timestamps
    end unless table_exists? :ddt_pay_items

    create_table :ddt_pay_methods do |t|
      t.references :shop, index: true
      t.string :name
      t.string :name_sym
      t.string :name_abbr
      t.string :code
      t.boolean :builtin, default: false
      t.boolean :enable, default: true
      t.boolean :is_actual, default: true
      t.timestamps
    end unless table_exists? :ddt_pay_methods

    index = 0
    all_index = Ddt::Shop.all.count
    Ddt::Shop.all.find_each do |shop|
      Ddt::ShopInitializer.new(shop).create_default_pay_method!
      puts "shop create_default_pay_method index : #{index}/#{all_index}" if index % 100 == 0
      index += 1
    end
    # pay_method  payment_state payment_total
    add_column :ddt_orders, :multi_pay_item, :boolean, default: false unless column_exists?(:ddt_orders, :multi_pay_item, :boolean)
    add_column :ddt_orders, :pay_method_names, :string unless column_exists?(:ddt_orders, :pay_method_names, :string)
    rename_column :ddt_orders, :payment_state, :pay_item_state unless column_exists?(:ddt_orders, :pay_item_state)
    rename_column :ddt_orders, :payment_total, :pay_item_total unless column_exists?(:ddt_orders, :pay_item_total)
    Ddt::Order.placed.where(pay_item_state: [:checkout, :processing, :pending, :void, :failed]).update_all(pay_item_state: :unpaid)
    Ddt::Order.placed.where(pay_item_state: [:completed]).update_all(pay_item_state: :paid)
    index = 0
    all_index = Ddt::Order.placed.all.count
    Ddt::PayItem.skip_callback(:save, :after, :change_to_paid)
    Ddt::PayItem.skip_callback(:save, :after, :update_payment)
    Ddt::PayItem.skip_callback(:create, :after, :init_payment)
    Ddt::Shop.all.find_each do |shop|
      Ddt::PayItem.transaction do
        puts "migrate for shop #{shop.id}"
        shop.orders.includes(:shop).find_each do |order|
          if order.pay_items.blank?
            pay_method = order.shop.pay_methods.builtin.find_by(name_sym: order.pay_method.try(:to_sym))
            if pay_method.present?
              pay_item = order.pay_items.build(pay_method: pay_method, amount: order.get_amount_for_pay)
              if pay_method.pay_platform?
                payment = order.payments.where(payment_method_id: pay_method.get_payment_method.try(:id)).first
                pay_item.payment_id = payment.try(:id)
              end
              if order.pay_item_state.try(:to_sym) == :paid
                pay_item.state = :paid
              end
              pay_item.save!
            end
            # order.update_column(:pay_method_names, order.pay_method_name)
          end
          puts "order create pay_item index : #{index}/#{all_index} #{Time.now.strftime("%F %T")}" if index % 100 == 0
          index += 1
        end
      end
    end
  end

  def down
    Ddt::Order.placed.where(pay_item_state: [:paid]).update_all(pay_item_state: :completed)
    rename_column :ddt_orders, :pay_item_total, :payment_total
    rename_column :ddt_orders, :pay_item_state, :payment_state
    remove_column :ddt_orders, :pay_method_names, :string
    remove_column :ddt_orders, :multi_pay_item, :boolean, default: false
    drop_table :ddt_pay_methods
    drop_table :ddt_pay_items
  end
end
