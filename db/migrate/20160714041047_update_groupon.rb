class UpdateGroupon < ActiveRecord::Migration
  def up
    # drop_table :ddt_groupon_line_items
    sql = <<-SQL.strip_heredoc
      select v.id, v.branch_id
      from ddt_abstract_coupon_versions v
      where v.type in ("Ddt::GrouponVersion", "Ddt::VoucherVersion");
    SQL
    result = execute(sql).to_a
    puts result.count
    rows = result.map{|r| "(#{r[0]}, #{r[1]})"}.join(',')
    sql = "insert into ddt_abstract_coupon_versions_branches (abstract_coupon_version_id, branch_id) values #{rows};"
    execute(sql)
  end

  def down

  end
end
