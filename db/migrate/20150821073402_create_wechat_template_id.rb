class CreateWechatTemplateId < ActiveRecord::Migration
  def change
    create_table :ddt_wechat_template_ids do |t|
      t.references :wechat_account, index: true
      t.string :template_id_short
      t.string :template_id
      t.integer :failed_count
      t.timestamps
    end

    add_index :ddt_wechat_template_ids, :template_id_short
    add_index :ddt_wechat_template_ids, :template_id
  end
end
