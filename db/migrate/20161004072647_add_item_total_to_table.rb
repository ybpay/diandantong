class AddItemTotalToTable < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_tables, :item_total
      add_column :ddt_tables, :item_total, :decimal, precision: 10, scale: 2, default: 0
    end

    unless column_exists? :ddt_tables, :track_from
      add_column :ddt_tables, :track_from, :string
    end
    Ddt::Table.where(:workflow_state => [:ordered, :check_outing, :paid]).find_each do |table|
      order = (Ddt::Order.find(table.current_order_id) rescue nil) if table.current_order_id.present?
      table.update(:track_from => order.track_from, :item_total => order.item_total) if order.present?
    end
  end
end
