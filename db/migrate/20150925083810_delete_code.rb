class DeleteCode < ActiveRecord::Migration
  def change
    [
      {klass: Ddt::Article, column: :url},
      {klass: Ddt::BranchSlider, column: :url},
      {klass: Ddt::HomeHotLink, column: :link},
      {klass: Ddt::HomeUsableLink, column: :link},
      {klass: Ddt::ShakeAround::Page, column: :page_url},
      {klass: Ddt::WechatMenu, column: :url}
    ].each do |item|
      item[:klass].where("#{item[:column]} like '%code=%'").find_each do |obj|
        puts "starts to migrate url for #{obj.send item[:column]}"
        params = {}
        params[item[:column]] = obj.filter_url(obj.send item[:column])
        obj.update_columns(params)
      end
      puts "=[#{item[:klass].name}] done======================================"
    end
  end
end
