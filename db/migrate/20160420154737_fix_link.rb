class FixLink < ActiveRecord::Migration
  def change

    execute <<-SQL
      update ddt_branch_sliders set url= REPLACE(url, '?#', '?_ng_path=')
      where (url REGEXP '^http://d.diandantong.com/weixin/shops/.+\\\\?#.+')=1
    SQL

    execute <<-SQL
      update ddt_home_hot_links set link= REPLACE(link, '?#', '?_ng_path=')
      where (link REGEXP '^http://d.diandantong.com/weixin/shops/.+\\\\?#.+')=1
    SQL

    execute <<-SQL
      update ddt_home_usable_links set link= REPLACE(link, '?#', '?_ng_path=')
      where (link REGEXP '^http://d.diandantong.com/weixin/shops/.+\\\\?#.+')=1
    SQL

  end
end
