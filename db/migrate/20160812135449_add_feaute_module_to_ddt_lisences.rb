class AddFeauteModuleToDdtLisences < ActiveRecord::Migration
  def change
    add_column :ddt_lisences, :feature_module, :string
  end
end
