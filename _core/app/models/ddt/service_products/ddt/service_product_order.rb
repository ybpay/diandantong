# encoding: utf-8
module Ddt
  class ServiceProductOrder < Ddt::Base

    ### relationships
    include BelongsToShop
    belongs_to :service_product, class_name: 'Ddt::ServiceProduct'

    ### validations
    validates :price, presence: true, numericality: {greater_than_or_equal_to: 0}
    validates :quantity, presence: true, numericality: {greater_than_or_equal_to: 0}
    validates :service_product, presence: true
    validates :product_type, presence: true

    ### callbacks
    after_find :check_is_expired
    before_validation :set_product_type

    ### scopes
    default_scope { order("created_at DESC") }

    include AASM
    aasm column: :workflow_state, initial: :new do
      state :new, :finished, :closed

      event :verify do
        transitions from: :new, to: :finished
      end
      event :fail do
        transitions from: :new, to: :closed
      end
    end

    def verify(params)
      service_product.perform(self.shop)
    rescue => e
      raise ActiveRecord::Rollback
    end

    def fail
    end

    def workflow_state_name
      I18n.t "activerecord.attributes.ddt/service_product_order.workflow_state_name.#{workflow_state}"
    end

    def product_type_name
      self.service_product.type_name
    end

    private
    def check_is_expired
      if self.aasm_state.to_sym == :new && self.created_at < 12.hours.ago
        self.fail!
      end
    end

    def set_product_type
      self.product_type = self.service_product.type
    end

  end
end
