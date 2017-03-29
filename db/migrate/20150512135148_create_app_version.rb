#encoding: utf-8
class CreateAppVersion < ActiveRecord::Migration
  def change
    create_table :ddt_app_versions do |t|
      t.string :os_type # android/ios
      t.string :version_name, default: '点单通卖家版' # '点单通'
      t.string :version_code # x.y.z    x.y.z
      t.string :note, default: '' # 备注，可以简单注明该版本的修改
      t.integer :code # (x << 16) + (y << 8) + z
      t.string :url
      t.timestamps
    end

    add_index :ddt_app_versions, :os_type
    add_index :ddt_app_versions, :version_code
    add_index :ddt_app_versions, :code
  end
end
