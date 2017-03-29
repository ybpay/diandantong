class MoveChangeMergeTableRecordToOrderChangeLog < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_order_change_logs, :from_table_id
      sql = ActiveRecord::Base.connection()
      sql.execute "SET autocommit=0"
      sql.begin_db_transaction
      sql.execute("CREATE TABLE ddt_order_change_logs_new LIKE ddt_order_change_logs")
      add_column :ddt_order_change_logs_new, :from_table_id, :integer
      add_column :ddt_order_change_logs_new, :to_table_id, :integer
      add_column :ddt_order_change_logs_new, :from_order_id, :integer
      add_column :ddt_order_change_logs_new, :to_order_id, :integer
      add_column :ddt_order_change_logs_new, :change_table_record_id, :integer
      add_column :ddt_order_change_logs_new, :merge_table_record_id, :integer
      sql.execute <<-SQL
        INSERT INTO ddt_order_change_logs_new
          SELECT *,
            NULL, NULL, NULL, NULL, NULL, NULL
          FROM ddt_order_change_logs
      SQL
      rename_table :ddt_order_change_logs, :ddt_order_change_logs_old
      rename_table :ddt_order_change_logs_new, :ddt_order_change_logs
      sql.commit_db_transaction
      sql.execute "SET autocommit=1"
    end
    execute <<-SQL
      DELETE FROM ddt_order_change_logs
        WHERE type in ("Ddt::OrderChangeLog::ChangeTable", "Ddt::OrderChangeLog::MergeTable");
    SQL
    execute <<-SQL
      INSERT INTO ddt_order_change_logs
        (change_table_record_id, shop_id, branch_id, order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, type)
        SELECT id, shop_id, branch_id, order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, "Ddt::OrderChangeLog::ChangeTable"
        FROM ddt_change_table_records;
    SQL
    execute <<-SQL
      INSERT INTO ddt_order_change_logs
        (merge_table_record_id, shop_id, branch_id, order_id, from_order_id, to_order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, type)
        SELECT id, shop_id, branch_id, from_order_id, from_order_id, to_order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, "Ddt::OrderChangeLog::MergeTable"
        FROM ddt_merge_table_records;
    SQL
    execute <<-SQL
      INSERT INTO ddt_order_change_logs
        (merge_table_record_id, shop_id, branch_id, order_id, from_order_id, to_order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, type)
        SELECT id, shop_id, branch_id, to_order_id, from_order_id, to_order_id, from_table_id, to_table_id, operator_type, operator_id, created_at, updated_at, "Ddt::OrderChangeLog::MergeTable"
        FROM ddt_merge_table_records;
    SQL

    # execute <<-SQL
    #   UPDATE ddt_notification_events event
    #   LEFT JOIN ddt_order_change_logs log ON log.change_table_record_id = event.change_table_record_id
    #     SET
    #       event.order_change_log_id = log.id,
    #       event.order_id = log.order_id
    #   WHERE event.type = "Ddt::Notification::Event::Table::Changed";
    # SQL
    # execute <<-SQL
    #   UPDATE ddt_notification_events event
    #   LEFT JOIN ddt_order_change_logs log ON log.merge_table_record_id = event.merge_table_record_id
    #     SET
    #       event.order_change_log_id = log.id,
    #       event.order_id = log.order_id
    #   WHERE event.type = "Ddt::Notification::Event::Table::Merged";
    # SQL
  end

  def down
    drop_table :ddt_order_change_logs
    rename_table :ddt_order_change_logs_old, :ddt_order_change_logs
  end
end
