class RemoveEnableDiscountToCategory < ActiveRecord::Migration
  def up
    category_ids = Ddt::Category.where(enable_discount: false).pluck(:id)
    sub_ids = Ddt::Category.where(parent_id: category_ids).pluck(:id)
    ids = [category_ids, sub_ids].flatten
    if ids.present?
      pids = ActiveRecord::Base.connection.execute("select product_id from ddt_categories_products where category_id in (#{ids.join(',')});").to_a.flatten.uniq
    else
      pids = []
    end
    Ddt::Product.where(id: pids).update_all(enable_discount: false)
    remove_column :ddt_categories, :enable_discount, :boolean, default: true
  end

  def down
    add_column :ddt_categories, :enable_discount, :boolean, default: true
  end
end
