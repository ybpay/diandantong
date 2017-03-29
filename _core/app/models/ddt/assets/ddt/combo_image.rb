module Ddt
  class ComboImage < Ddt::Image
    replicated_model

    include Ddt::Core::Engine.routes.url_helpers
    mount_uploader :attachment, ComboImageUploader

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
