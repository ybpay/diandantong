class AddTypeToTag < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_tags, :type
      add_column :ddt_tags, :type, :string
    end
    Ddt::Tag.update_all(type: 'Ddt::ProductTag')
  end
end
