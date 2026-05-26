class AddPayMethodInfoToPayItem < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_pay_items, :pay_method_name
      sql = ActiveRecord::Base.connection()
      sql.begin_db_transaction
      sql.execute("CREATE TABLE ddt_pay_items_new (LIKE ddt_pay_items INCLUDING ALL)")
      add_column :ddt_pay_items_new, :pay_method_name, :string
      add_column :ddt_pay_items_new, :pay_method_name_sym, :string
      add_column :ddt_pay_items_new, :pay_method_code, :string
      add_column :ddt_pay_items_new, :pay_method_is_actual, :boolean, default: true
      add_column :ddt_pay_items_new, :pay_method_builtin, :boolean, default: false

      # Build explicit column list for INSERT and SELECT
      columns = sql.columns('ddt_pay_items').map(&:name)
      new_columns = %w[pay_method_name pay_method_name_sym pay_method_code pay_method_is_actual pay_method_builtin]
      insert_cols = (columns + new_columns).join(', ')
      select_cols = columns.join(', ') + ', NULL, NULL, NULL, TRUE, FALSE'

      sql.execute <<-SQL
        INSERT INTO ddt_pay_items_new (#{insert_cols})
          SELECT #{select_cols}
          FROM ddt_pay_items
      SQL
      rename_table :ddt_pay_items, :ddt_pay_items_old
      rename_table :ddt_pay_items_new, :ddt_pay_items
      sql.commit_db_transaction
    end
    execute <<-SQL
      UPDATE ddt_pay_items
      SET pay_method_name      = pay_method.name,
          pay_method_name_sym  = pay_method.name_sym,
          pay_method_code      = pay_method.code,
          pay_method_is_actual = pay_method.is_actual,
          pay_method_builtin   = pay_method.builtin
      FROM ddt_pay_methods pay_method
      WHERE ddt_pay_items.pay_method_id = pay_method.id;
    SQL
  end

  def down
    drop_table :ddt_pay_items
    rename_table :ddt_pay_items_old, :ddt_pay_items
  end
end
