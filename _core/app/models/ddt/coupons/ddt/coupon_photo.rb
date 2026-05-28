module Ddt
  class CouponPhoto < Ddt::Base
    include Ddt::BelongsToShop

    #### relationships
    belongs_to :owner, polymorphic: true

    include Ddt::Attachable
    attachable_one :image, variants: { medium: [720, 360], thumb: [240, 120], thumb_square: [120, 120] }

    ####validations
    validates :image, presence: true, on: :create
    validates :image, :file_size => {
        :maximum => 0.5.megabytes.to_i
      }

    ### callbacks
    set_from :owner
    before_validation do
      if attachment_changes[:image].present?
        blob = attachment_changes[:image].attachable
        self.size = blob.is_a?(ActiveStorage::Blob) ? blob.byte_size : File.size(blob)
      end
    end

  end
end
