class MoveChangeMergeTableRecordToOrderChangeLog < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_order_change_logs, :from_table_id
      sql = ActiveRecord::Base.connection()
      sql.begin_db_transaction
      sql.execute("CREATE TABLE ddt_order_change_logs_new (LIKE ddt_order_change_logs INCLUDING ALL)")
      add_column :ddt_order_change_logs_new, :from_table_id, :integer
      add_column :ddt_order_change_logs_new, :to_table_id, :integer
      add_column :ddt_order_change_logs_new, :from_order_id, :integer
      add_column :ddt_order_change_logs_new, :to_order_id, :integer
      add_column :ddt_order_change_logs_new, :change_table_record_id, :integer
      add_column :ddt_order_change_logs_new, :merge_table_record_id, :integer

      # Get column names from the original table and append the new columns
      columns = sql.columns('ddt_order_change_logs').map(&:name)
      new_columns = %w[from_table_id to_table_id from_order_id to_order_id change_table_record_id merge_table_record_id]
      # Build explicit column list for INSERT target
      insert_cols = (columns + new_columns).join(', ')
      # Build SELECT list: all original columns + NULLs for new columns
      select_cols = columns.join(', ') + ', ' + new_columns.map { |_| 'NULL' }.join(', ')

      sql.execute <<-SQL
        INSERT INTO ddt_order_change_logs_new (#{insert_cols})
          SELECT #{select_cols}
          FROM ddt_order_change_logs
      SQL
      rename_table :ddt_order_change_logs, :ddt_order_change_logs_old
      rename_table :ddt_order_change_logs_new, :ddt_order_change_logs
      sql.commit_db_transaction
    end
    execute <<-SQL
      DELETE FROM ddt_order_change_logs
        WHERE type in ('Ddt::OrderChangeLog::ChangeTable', 'Ddt::OrderChangeLog::MergeTable');
    SQL
    execute <<-SQL
      INSERT INTO ddt_order_change_logs
        (change_table_record_id, shop_id, branch_id, order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, type)
        SELECT id, shop_id, branch_id, order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, 'Ddt::OrderChangeLog::ChangeTable'
        FROM ddt_change_table_records;
    SQL
    execute <<-SQL
      INSERT INTO ddt_order_change_logs
        (merge_table_record_id, shop_id, branch_id, order_id, from_order_id, to_order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, type)
        SELECT id, shop_id, branch_id, from_order_id, from_order_id, to_order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, 'Ddt::OrderChangeLog::MergeTable'
        FROM ddt_merge_table_records;
    SQL
    execute <<-SQL
      INSERT INTO ddt_order_change_logs
        (merge_table_record_id, shop_id, branch_id, order_id, from_order_id, to_order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, type)
        SELECT id, shop_id, branch_id, to_order_id, from_order_id, to_order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, 'Ddt::OrderChangeLog::MergeTable'
        FROM ddt_merge_table_records;
    SQL

    # execute <<-SQL
    #   UPDATE ddt_notification_events
    #   SET order_change_log_id = log.id,
    #       order_id = log.order_id
    #   FROM ddt_order_change_logs log
    #   WHERE ddt_notification_events.change_table_record_id = log.change_table_record_id
    #     AND ddt_notification_events.type = 'Ddt::Notification::Event::Table::Changed';
    # SQL
    # execute <<-SQL
    #   UPDATE ddt_notification_events
    #   SET order_change_log_id = log.id,
    #       order_id = log.order_id
    #   FROM ddt_order_change_logs log
    #   WHERE ddt_notification_events.merge_table_record_id = log.merge_table_record_id
    #     AND ddt_notification_events.type = 'Ddt::Notification::Event::Table::Merged';
    # SQL
  end

  def down
    drop_table :ddt_order_change_logs
    rename_table :ddt_order_change_logs_old, :ddt_order_change_logs
  end
end
