class AddDeletedAtToPayMethod < ActiveRecord::Migration
  def change
    add_column :ddt_pay_methods, :deleted_at, :datetime
  end
end
