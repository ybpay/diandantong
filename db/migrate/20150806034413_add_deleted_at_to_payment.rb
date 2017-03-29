class AddDeletedAtToPayment < ActiveRecord::Migration
  def change
    add_column :ddt_payments, :deleted_at, :datetime
  end
end
