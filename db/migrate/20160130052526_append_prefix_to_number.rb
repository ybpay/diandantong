class AppendPrefixToNumber < ActiveRecord::Migration
  def change
  	execute <<-SQL.strip_heredoc
      update ddt_orders set number = CONCAT('B', number) where number is not null;
    SQL
  end
end
