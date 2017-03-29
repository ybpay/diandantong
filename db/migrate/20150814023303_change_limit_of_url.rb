class ChangeLimitOfUrl < ActiveRecord::Migration
  def change

    items = [
        #{ table: :ddt_agents,                 column: :wechat_introduce_url },
        #{ table: :ddt_branch_sliders,         column: :url },
        { table: :ddt_js_errors,              column: :url },
        { table: :ddt_message_receptions,     column: :url },
        { table: :ddt_message_response_items, column: :url },
        { table: :ddt_message_responses,      column: :url },
        #{ table: :ddt_pages,                  column: :page_url },
        #{ table: :ddt_pages,                  column: :icon_url },
        { table: :ddt_wechat_menus,           column: :url },
        #{ table: :ddt_home_hot_links,         column: :link },
        #{ table: :ddt_home_usable_links,      column: :link },
        #{ table: :ddt_shops,                  column: :custom_brand_link },
        #{ table: :ddt_web_modules,            column: :nav_link_1 },
        #{ table: :ddt_web_modules,            column: :nav_link_2 },
        { table: :ddt_wechat_share_records,   column: :link }
    ]

    items.each do |item|
      change_column item[:table], item[:column], :string, limit: 2048
      puts "===> ChangeUrlLimit finish,  table: #{item[:table]} coilumn: #{item[:column]}"
    end

  end
end
