module Ddt
  class Address < Ddt::Base
    acts_as_paranoid

    include Ddt::ListScope
    include LatLng

    filter_unicode_for :name, :room_no, :building
    belongs_to :base_user, class_name: 'Ddt::BaseUser'
    delegate :shop, to: :base_user
    validates_presence_of :name, :phone, :building
    validates :phone, length: 3..20
    validates :latitude,  :numericality => {:greater_than => -90, :less_than => 90}, allow_blank: true
    validates :longitude, :numericality => {:greater_than => -180, :less_than => 180}, allow_blank: true
    valid_phone :phone

    acts_as_list scope: [:base_user, :deleted_at]

    scope :default, ->{ where(is_default: true) }

    before_create :set_default_if_first
    after_save :set_not_default
    after_destroy :reset_default

    default_scope ->{ order(created_at: :desc) }

    def set_default
      self.update_attribute(:is_default, true)
      set_other_addresses_not_default
      self.base_user.update(:phone=> phone)
    end

    def content
      "#{building} - #{room_no}"
    end

    private
    def set_default_if_first
      self.is_default = true if self.base_user.addresses.blank?
    end

    def set_not_default
      set_other_addresses_not_default if self.is_default
    end

    def reset_default
      set_first_address_default if self.is_default
    end

    def set_other_addresses_not_default
      self.base_user.addresses.where.not(id: self.id).update_all(is_default: false)
    end

    def set_first_address_default
      if self.base_user.present?
        address = self.base_user.addresses.first
        address.update_column(:is_default, true) if address.present?
      end
    end

  end
end
