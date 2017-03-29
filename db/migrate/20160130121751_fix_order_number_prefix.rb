class FixOrderNumberPrefix < ActiveRecord::Migration
  def up
    execute <<-SQL.strip_heredoc
      update ddt_orders set number = IF(number REGEXP '^[1-9]', CONCAT('B', number), number) where number is not null;
    SQL
  end

  def down

  end
end
