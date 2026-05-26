class AddIndexToNotesProducts < ActiveRecord::Migration
  def change
    add_index :ddt_item_notes_products, [:product_id, :item_note_id], name: "index_inp_on_pid_and_inid"
    add_index :ddt_item_notes_products, [:item_note_id], name: "index_inp_on_inid"
    add_index :ddt_item_notes_tags, [:item_note_id, :tag_id], name: "index_intag_on_inid_and_tid"
    add_index :ddt_item_notes_tags, [:tag_id], name: "index_intag_on_tid"
    add_index :ddt_push_channels, :account_id
    add_index :ddt_bill_template_settings, :updated_at
    add_index :ddt_abstract_coupon_versions, :branch_id
    add_index :ddt_wechat_accounts, :authorizer_appid
    add_index :ddt_cs_branch_bindings, :token
    add_index :ddt_comments, :order_id
    remove_index :ddt_promotions_promotion_events, name: "index_ddt_ppe_on_promotion"
    add_index :ddt_promotions_promotion_events, [:promotion_id, :promotion_event_id], name: "index_ddt_ppe_on_pid_and_peid"
  end
end
