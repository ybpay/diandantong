module Ddt
  class CouponPhoto < Ddt::Base
    include Ddt::BelongsToShop

    #### relationships
    belongs_to :owner, polymorphic: true

    include Ddt::CarrierWaveBridge
    mount_uploader :image, CouponImageUploader

    ####validations
    validates :image, presence: true, on: :create
    validates :image, :file_size => {
        :maximum => 0.5.megabytes.to_i
      }

    ### callbacks
    set_from :owner
    before_validation do
      if image && image_changed?
        self.size = image.file.size
      end
    end

  end
end
