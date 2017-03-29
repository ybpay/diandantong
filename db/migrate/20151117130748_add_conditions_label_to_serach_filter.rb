class AddConditionsLabelToSerachFilter < ActiveRecord::Migration
  def change
    add_column :ddt_search_filters, :conditions_label, :string
  end
end
