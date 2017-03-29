#encoding: utf-8
module Ddt
  class CensorReport < Base
    include BelongsToShop
    belongs_to :base_user, class_name: 'Ddt::BaseUser'
    belongs_to :auditor, class_name: 'Ddt::Account'
    scope :of_unchecked, -> {where(:state => :unchecked)}
    validates_presence_of :title, :desc, :base_user

    state_machine :state, initial: :unchecked do
      event :confirm do
        transition all => :confirmed
      end
      event :reject do
        transition all => :rejected
      end
    end

  end
end