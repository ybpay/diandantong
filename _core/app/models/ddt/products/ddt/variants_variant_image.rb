module Ddt
  class VariantsVariantImage < Ddt::Base
    include Ddt::ListScope
    replicated_model

    belongs_to :variant, class_name: 'Ddt::Variant'
    belongs_to :variant_image, class_name: 'Ddt::VariantImage'
    acts_as_list scope: [:variant_id]


    after_create :update_variant_cache_info
    after_destroy :update_variant_cache_info
    after_destroy :destroy_variant_image

    class << self
      def link_on_image(image_id)
        where(variant_image_id: image_id).first
      end
    end

    private

      def destroy_variant_image
        if variant_image.variants.count == 0 && !variant_image.is_global?
          variant_image.destroy
        end
      end

      def update_variant_cache_info
        return if variant.blank?
        if variant.is_master?
          variant.product.variants_including_master.each(&:update_cache_info) if variant.product.present?
        else
          variant.update_cache_info
        end
      end

  end
end
