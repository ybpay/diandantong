class BackUpLinks < ActiveRecord::Migration
  def change

    unless column_exists? :ddt_articles, :url_bak
      add_column :ddt_articles, :url_bak, :text
      Ddt::Article.update_all('url_bak=url')
    end

    unless column_exists? :ddt_branch_sliders, :url_bak
      add_column :ddt_branch_sliders, :url_bak, :text
      Ddt::BranchSlider.update_all('url_bak=url')
    end

    unless column_exists? :ddt_home_hot_links, :link_bak
      add_column :ddt_home_hot_links, :link_bak, :string, limit: 2048
      Ddt::HomeHotLink.update_all('link_bak=link')
    end

    unless column_exists? :ddt_home_usable_links, :link_bak
      add_column :ddt_home_usable_links, :link_bak, :string, limit: 2048
      Ddt::HomeUsableLink.update_all('link_bak=link')
    end

  end
end
