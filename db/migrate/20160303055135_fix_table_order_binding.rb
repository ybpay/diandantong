class FixTableOrderBinding < ActiveRecord::Migration
  def up
    # find illegal order and tables
    # select o.id o_id, o.shop_id o_sid, o.branch_id o_bid, t.id t_id, t.shop_id t_sid, t.branch_id t_bid

    # 寻找有订单 shop_id, branch_id 与其桌台不一致的订单
    rs = execute <<-SQL.strip_heredoc
      select o.id id, o.branch_id branch_id
      from ddt_orders o
      inner join ddt_tables t
      on o.table_id = t.id
      where o.shop_id != t.shop_id or o.branch_id != t.branch_id;
    SQL

    rs.each do |row|
      order_id = row[0]
      branch_id = row[1]
      # 随机找一个桌台绑定
      table_id = Ddt::Branch.find(branch_id).tables.first.id

      execute <<-SQL.strip_heredoc
        update ddt_orders
        set table_id = #{table_id}
        where id = #{order_id}
      SQL
    end
  end

  def down
  end

end
