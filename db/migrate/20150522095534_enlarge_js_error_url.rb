class EnlargeJsErrorUrl < ActiveRecord::Migration
  def change
    remove_index :ddt_js_errors, :url
    change_column :ddt_js_errors, :url, :string, limit: 512
  end
end
