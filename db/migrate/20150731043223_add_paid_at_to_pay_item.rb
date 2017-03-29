class AddPaidAtToPayItem < ActiveRecord::Migration
  def up
    add_column :ddt_pay_items, :paid_at, :datetime
    execute <<-SQL
      UPDATE ddt_pay_items p
      JOIN ddt_orders o ON p.order_id = o.id
      SET p.paid_at = o.paid_at
      where o.paid_at is not null and p.state = 'paid';
    SQL
    execute <<-SQL
      UPDATE ddt_pay_items p
      SET p.paid_at = p.updated_at
      where p.paid_at is null and p.state = 'paid';
    SQL
  end

  def down
    remove_column :ddt_pay_items, :paid_at, :datetime
  end
end
