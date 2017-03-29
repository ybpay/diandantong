class AddPayMethodInfoToPayItem < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_pay_items, :pay_method_name
      sql = ActiveRecord::Base.connection()
      sql.execute "SET autocommit=0"
      sql.begin_db_transaction
      sql.execute("CREATE TABLE ddt_pay_items_new LIKE ddt_pay_items")
      add_column :ddt_pay_items_new, :pay_method_name, :string
      add_column :ddt_pay_items_new, :pay_method_name_sym, :string
      add_column :ddt_pay_items_new, :pay_method_code, :string
      add_column :ddt_pay_items_new, :pay_method_is_actual, :boolean, default: true
      add_column :ddt_pay_items_new, :pay_method_builtin, :boolean, default: false
      sql.execute <<-SQL
        INSERT INTO ddt_pay_items_new
          SELECT *,
            NULL, NULL, NULL, 1, 0
          FROM ddt_pay_items
      SQL
      rename_table :ddt_pay_items, :ddt_pay_items_old
      rename_table :ddt_pay_items_new, :ddt_pay_items
      sql.commit_db_transaction
      sql.execute "SET autocommit=1"
    end
    execute <<-SQL
      UPDATE ddt_pay_items pay_item
      LEFT JOIN ddt_pay_methods pay_method ON pay_item.pay_method_id = pay_method.id
      SET
        pay_item.pay_method_name      = pay_method.name,
        pay_item.pay_method_name_sym  = pay_method.name_sym,
        pay_item.pay_method_code      = pay_method.code,
        pay_item.pay_method_is_actual = pay_method.is_actual,
        pay_item.pay_method_builtin   = pay_method.builtin;
    SQL
  end

  def down
    drop_table :ddt_pay_items
    rename_table :ddt_pay_items_old, :ddt_pay_items
  end
end
