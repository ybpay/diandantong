class CreateTagForBranchType < ActiveRecord::Migration

  def change
    add_column :ddt_tags, :branch_type_id, :integer unless column_exists? :ddt_tags, :branch_type_id
    execute <<-SQL
      insert into ddt_tags(branch_type_id, name, count, shop_id, type, created_at, updated_at)
       select id, name, branches_count, shop_id, 'Ddt::BranchTag',now(),now() from ddt_branch_types;
    SQL
    execute <<-SQL
      insert into ddt_branches_tags(branch_id, tag_id) select b.id, t.id from ddt_branches as b left join ddt_tags as t on b.branch_type_id = t.branch_type_id;
    SQL
  end

end
