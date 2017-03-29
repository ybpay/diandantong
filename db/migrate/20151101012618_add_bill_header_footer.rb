class AddBillHeaderFooter < ActiveRecord::Migration
  def change
    change_column :ddt_print_settings, :page_header, :text
    change_column :ddt_print_settings, :page_footer, :text
    add_column :ddt_print_settings, :consume_bill_header, :text
    add_column :ddt_print_settings, :consume_bill_footer, :text
    add_column :ddt_print_settings, :product_bill_header, :text
    add_column :ddt_print_settings, :product_bill_footer, :text
  end
end
