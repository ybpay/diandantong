class AddHashStrToAssets < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_assets, :hex_str
      add_column :ddt_assets, :hex_str, :string, limit: 191
      add_index :ddt_assets, :hex_str
    end


    count = 0
    Ddt::Asset.where(hex_str: nil).find_each do |asset|
      count += 1
      puts "MigrateAssets(#{count}th), id: #{asset.id}" if count%100 == 0
      asset.update_column(:hex_str, Digest::MD5.hexdigest(asset.id.to_s))
    end
  end
end
