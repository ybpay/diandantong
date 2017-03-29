class FixBranchTypeLinks < ActiveRecord::Migration
  def change

    execute <<-SQL
      update ddt_branch_sliders set url= REPLACE(url, 'branch_type_id_eq', 'branch_tag_id_eq')
      where (url REGEXP '.+/weixin/shops/.+branch_type_id_eq.+')=1
    SQL

    execute <<-SQL
      update ddt_home_hot_links set link= REPLACE(link, 'branch_type_id_eq', 'branch_tag_id_eq')
      where (link REGEXP '.+/weixin/shops/.+branch_type_id_eq.+')=1
    SQL

    execute <<-SQL
      update ddt_home_usable_links set link= REPLACE(link, 'branch_type_id_eq', 'branch_tag_id_eq')
      where (link REGEXP '.+/weixin/shops/.+branch_type_id_eq.+')=1
    SQL

    # 替换
    execute <<-SQL
      update ddt_branch_sliders as l
      left join ddt_tags as t on SUBSTRING_INDEX(url, 'branch_tag_id_eq%5D%3D', -1) = t.branch_type_id
      set url = concat(SUBSTRING_INDEX(url, 'branch_tag_id_eq%5D%3D', 1), 'branch_tag_id_eq%5D%3D', t.id)
      where(url REGEXP '.+/weixin/shops/.+branch_tag_id_eq.+')=1
    SQL

    execute <<-SQL
      update ddt_home_hot_links as l
      left join ddt_tags as t on SUBSTRING_INDEX(link, 'branch_tag_id_eq%5D%3D', -1) = t.branch_type_id
      set link = concat(SUBSTRING_INDEX(link, 'branch_tag_id_eq%5D%3D', 1), 'branch_tag_id_eq%5D%3D', t.id)
      where(link REGEXP '.+/weixin/shops/.+branch_tag_id_eq.+')=1
    SQL

    execute <<-SQL
      update ddt_home_usable_links as l
      left join ddt_tags as t on SUBSTRING_INDEX(link, 'branch_tag_id_eq%5D%3D', -1) = t.branch_type_id
      set link = concat(SUBSTRING_INDEX(link, 'branch_tag_id_eq%5D%3D', 1), 'branch_tag_id_eq%5D%3D', t.id)
      where(link REGEXP '.+/weixin/shops/.+branch_tag_id_eq.+')=1
    SQL

  end
end
