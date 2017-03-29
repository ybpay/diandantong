class DeleteUnpresentEssentialProduct < ActiveRecord::Migration
  def change

    Ddt::EssentialProduct.find_each do |p|
      unless p.variant.present?
        p.destroy
      end
    end

  end
end
