class MoveAssociation < ActiveRecord::Migration
  def change
    count = 0
    Ddt::VariantImage.find_each do |image|
      count += 1
      puts "MoveAssociation(#{count}th): id: #{image.id}" if count % 100 == 0
      params = {variant_id: image.viewable_id, variant_image_id: image.id, position: image.position}
      Ddt::VariantsVariantImage.create(params)
    end
  end
end
