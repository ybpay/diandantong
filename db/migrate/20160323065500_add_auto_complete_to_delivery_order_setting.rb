class AddAutoCompleteToDeliveryOrderSetting < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_delivery_settings, :enable_auto_complete
      add_column :ddt_delivery_settings, :enable_auto_complete, :boolean, default: false, null: false
    end
  end
end
