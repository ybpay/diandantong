#encoding: utf-8
module Ddt
  class CensorReport < Base
    include BelongsToShop
    include AASM
    belongs_to :base_user, class_name: 'Ddt::BaseUser'
    belongs_to :auditor, class_name: 'Ddt::Account'
    scope :of_unchecked, -> {where(:state => :unchecked)}
    validates_presence_of :title, :desc, :base_user

    aasm column: :state do
      state :unchecked, :confirmed, :rejected, initial: :unchecked

      event :confirm do
        transitions from: any, to: :confirmed
      end
      event :reject do
        transitions from: any, to: :rejected
      end
    end

  end
end