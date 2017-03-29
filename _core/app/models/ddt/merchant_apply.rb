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
    include Workflow
    workflow do
      state :applying do
        event :confirm, transition_to: :confirmed
        event :reject, transition_to: :rejected
        event :cancel, transition_to: :canceled
      end
      state :confirmed
      state :rejected
      state :canceled
    end

  end
end
