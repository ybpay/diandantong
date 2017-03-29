class AddCancelReasonToOrder < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_orders, :cancel_reason
      add_column :ddt_orders, :cancel_reason, :string
    end
  end
end
