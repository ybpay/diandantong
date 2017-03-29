class AddFromBranchIdToUser < ActiveRecord::Migration
  def change
    add_column :ddt_base_users, :from_branch_id, :integer, index: true
    add_column :ddt_vip_infos, :from_branch_id, :integer, index: true
    add_column :ddt_vip_infos, :become_vip_at, :datetime
    sql = <<-sql
      update ddt_vip_infos
      set become_vip_at = created_at
      where become_vip_at is null;
    sql
    execute(sql)
  end
end