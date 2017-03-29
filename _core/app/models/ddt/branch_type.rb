module Ddt
  class BranchType < Ddt::Base
    ### relationships
    replicated_model

    belongs_to :shop, class_name: 'Ddt::Shop', touch: true
    has_many :branches, class_name: 'Ddt::Branch'
    validates :icon, icon: true, allow_blank: true
    mount_uploader :image, BranchTypeImageUploader
    mount_uploader :reservation_img, ShopButtonImageUploader
    mount_uploader :order_in_seat_img, ShopButtonImageUploader
    mount_uploader :delivery_img, ShopButtonImageUploader
    mount_uploader :fastfood_img, ShopButtonImageUploader
    mount_uploader :queue_img, ShopButtonImageUploader
    mount_uploader :pay_online_img, ShopButtonImageUploader



    ### validations
    validates :reservation_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :reservation_img?
    validates :order_in_seat_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :order_in_seat_img?
    validates :delivery_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :delivery_img?
    validates :fastfood_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :fastfood_img?
    validates :queue_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :queue_img?
    validates :pay_online_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :pay_online_img?

    before_destroy do
        if self.branches.present?
            self.errors.add(:branches, I18n.t('can not destroy branch type as it have branches'))
            false
        end
    end

    ### validations
    validates :name, presence: true
    validates :image,
      :file_size => {
        :maximum => 0.2.megabytes.to_i
      }, if: :image?
  end
end
