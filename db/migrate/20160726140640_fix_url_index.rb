class FixUrlIndex < ActiveRecord::Migration
  def up
    change_column :ddt_js_errors, :url, :string, limit: 1024
    add_index :ddt_js_errors, :url
  end

  def down
  end
end
