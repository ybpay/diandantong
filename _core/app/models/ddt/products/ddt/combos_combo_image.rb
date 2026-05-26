module Ddt
  class CombosComboImage < Ddt::Base
    include Ddt::ListScope

    belongs_to :combo, class_name: 'Ddt::Combo', touch: true
    belongs_to :combo_image, class_name: 'Ddt::ComboImage'
    acts_as_list scope: [:combo_id]

    after_destroy :destroy_combo_image

    class << self
      def link_on_image(image_id)
        where(combo_image_id: image_id).first
      end
    end

    private

      def destroy_combo_image
        if combo_image.combos.count == 0 && !combo_image.is_global?
          combo_image.destroy
        end
      end

  end
end
