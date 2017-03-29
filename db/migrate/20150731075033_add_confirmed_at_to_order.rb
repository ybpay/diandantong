class AddConfirmedAtToOrder < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_orders, :confirmed_at
      add_column :ddt_orders, :confirmed_at, :datetime
      Ddt::Order.where(state: [:confirmed, :completed]).update_all("confirmed_at=updated_at")
    end

    unless column_exists? :ddt_orders, :canceled_at
      add_column :ddt_orders, :canceled_at, :datetime
      Ddt::Order.where(state: :canceled).update_all("canceled_at=updated_at")
    end
  end
end
