class DevAddBillTemplate < ActiveRecord::Migration
  def up
    unless table_exists? :ddt_bill_template_settings
      create_table :ddt_bill_template_settings do |t|
        t.references :shop, index: true
        t.references :branch, index: true
        t.text :order_product_bill_template,              limit: 10000
        t.text :order_consume_bill_template,              limit: 10000
        t.text :order_append_product_bill_template,       limit: 10000
        t.text :order_bill_template,                      limit: 10000
        t.text :order_short_bill_template,                limit: 10000
        t.text :order_one_by_one_bill_template,           limit: 10000
        t.text :order_per_product_bill_template,          limit: 10000
        t.text :order_label_bill_template,                limit: 10000
        t.text :order_append_bill_template,               limit: 10000
        t.text :order_append_one_by_one_bill_template,    limit: 10000
        t.text :order_append_per_product_bill_template,   limit: 10000
        t.text :order_subtract_bill_template,             limit: 10000
        t.text :order_subtract_one_by_one_bill_template,  limit: 10000
        t.text :order_subtract_per_product_bill_template, limit: 10000
        t.text :order_hasten_bill_template,               limit: 10000
        t.text :order_hasten_item_bill_template,          limit: 10000
        t.text :order_reprint_bill_template,              limit: 10000
        t.text :queue_enqueueing_bill_template,           limit: 10000
        t.text :queue_pre_order_bill_template,            limit: 10000
        t.timestamps
      end
    end
    Ddt::Branch.all.find_each do |branch|
      branch.create_bill_template_setting
    end
  end

  def down
    drop_table :ddt_bill_template_settings if table_exists? :ddt_bill_template_settings
  end
end
