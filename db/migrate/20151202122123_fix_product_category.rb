class FixProductCategory < ActiveRecord::Migration
  def change
    Ddt::Branch.find_each do |branch|
      category = branch.categories.first
      unless category.nil?
        branch.products.each do |product|
          if product.categories.blank?
            product.categories << category
            product.save
          end
        end
      end
    end
  end
end
