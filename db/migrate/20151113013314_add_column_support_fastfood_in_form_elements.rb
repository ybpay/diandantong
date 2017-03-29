class AddColumnSupportFastfoodInFormElements < ActiveRecord::Migration
  def change
    add_column :ddt_form_elements, :support_fastfood, :boolean, default: false unless column_exists? :ddt_form_elements, :support_fastfood
  end
end
