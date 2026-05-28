module Ddt
  class VariantImage < Ddt::Image

    include Ddt::Core::Engine.routes.url_helpers
    include Ddt::Attachable
    attachable_one :attachment, variants: { small: [100, 100], rect_normal: [240, 133], rect_large: [720, 400] }

    has_many :variants_variant_images, class_name: 'Ddt::VariantsVariantImage'
    has_many :variants, class_name: 'Ddt::Variant', through: :variants_variant_images

    def to_jq_upload(variant)
      {
        "name"          => read_attribute(:attachment),
        "size"          => self.file_size,
        "url"           => attachment.url,
        "thumbnail_url" => attachment.rect_normal.url,
        "delete_url"    => backend_shop_branch_product_variant_variant_image_path(variant.shop, variant.branch, variant.product, variant, self),
        "delete_type"   => "DELETE"
      }
    end

    def set_global
      self.update(is_global: true)
      variant = self.variants.first
      if self.asset_tags.count == 0 && variant.present?
        self.asset_tags << Ddt::AssetTag.find_or_create_by(name: variant.name)
      end
    end

  end
end
