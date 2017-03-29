class AddTypeToAbstractSource < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_abstract_sources, :type
      add_column :ddt_abstract_sources, :type, :string
    end
  end
end
