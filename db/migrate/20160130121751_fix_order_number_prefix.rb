class FixOrderNumberPrefix < ActiveRecord::Migration
  def up
    execute <<-SQL.strip_heredoc
      UPDATE ddt_orders SET number = CASE WHEN number ~ '^[1-9]' THEN 'B' || number ELSE number END WHERE number IS NOT NULL;
    SQL
  end

  def down

  end
end
