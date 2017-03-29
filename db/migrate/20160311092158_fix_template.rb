module Ddt
  class BillTemplateSettingOld < ActiveRecord::Base
    self.table_name = "ddt_bill_template_settings_old"
  end
end
class FixTemplate < ActiveRecord::Migration
  def up
    unless table_exists? :ddt_bill_template_settings_new
      sql = ActiveRecord::Base.connection()
      sql.execute "SET autocommit=0"
      sql.begin_db_transaction
      create_table :ddt_bill_template_settings_new do |t|
        t.integer  "shop_id"
        t.integer  "branch_id"
        t.boolean  "enable", default: false
        t.text     "templates"
        t.datetime "created_at"
        t.datetime "updated_at"
      end
      sql.execute <<-SQL
        INSERT INTO ddt_bill_template_settings_new
          SELECT id, shop_id, branch_id, created_at != updated_at, NULL, created_at, updated_at
          FROM ddt_bill_template_settings
      SQL
      rename_table :ddt_bill_template_settings, :ddt_bill_template_settings_old
      rename_table :ddt_bill_template_settings_new, :ddt_bill_template_settings
      sql.commit_db_transaction
      sql.execute "SET autocommit=1"
    end

    Ddt::BillTemplateSetting.where(enable: true).find_each do |setting|
      old_setting = Ddt::BillTemplateSettingOld.find(setting.id)
      Ddt::BillTemplateSetting.all_templates.each do |template|
        setting.templates[template] = old_setting.send(template)
      end
      setting.save!
    end

  end

  def down
    drop_table :ddt_bill_template_settings if table_exists? :ddt_bill_template_settings
    rename_table :ddt_bill_template_settings_old, :ddt_bill_template_settings
  end
end
