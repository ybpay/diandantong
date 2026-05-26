# encoding: utf-8
module Ddt
  class MerchantApply < Ddt::Base

    ### relationships
    belongs_to :shop
    belongs_to :user

    ### validations
    validates :shop, presence: true
    validates :user, presence: true
    validates :phone, presence: true
    validates :note, presence: true

    STATES = [:applying, :confirmed, :rejected, :canceled]
    acts_as_type :workflow_state, STATES, STATES.map { |state| I18n.t("activerecord.attributes.ddt/merchant_apply.states.#{state}") }
    include AASM
    aasm column: :workflow_state, initial: :applying do
      state :applying, :confirmed, :rejected, :canceled

      event :confirm do
        transitions from: :applying, to: :confirmed
      end
      event :reject do
        transitions from: :applying, to: :rejected
      end
      event :cancel do
        transitions from: :applying, to: :canceled
      end
    end

  end
end
