class AppendPrefixToNumber < ActiveRecord::Migration
  def change
  	execute <<-SQL.strip_heredoc
      UPDATE ddt_orders SET number = 'B' || number WHERE number IS NOT NULL;
    SQL
  end
end
