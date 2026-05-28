module Ddt
  class ComboImage < Ddt::Image

    include Ddt::Core::Engine.routes.url_helpers
    include Ddt::Attachable
    attachable_one :attachment, variants: { small: [100, 100], rect_normal: [240, 133], rect_large: [720, 400] }

    has_many :combos_combo_images, class_name: 'Ddt::CombosComboImage'
    has_many :combos, class_name: 'Ddt::Combo', through: :combos_combo_images

    def to_jq_upload(combo)
      {
        "name"          => read_attribute(:attachment),
        "size"          => self.file_size,
        "url"           => attachment.url,
        "thumbnail_url" => attachment.rect_normal.url,
        "delete_url"    => backend_shop_branch_combo_combo_image_path(combo.shop, combo.branch, combo, self),
        "delete_type"   => "DELETE"
      }
    end

  end
end
