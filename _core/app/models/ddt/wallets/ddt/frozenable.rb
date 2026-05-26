# encoding:utf-8
module Ddt
  module Frozenable
    extend ActiveSupport::Concern
    included do
      include AASM
      acts_as_type :state, [:pending, :completed, :canceled], %W(已冻结 已完成 已回滚)
      aasm column: :state do
        state :pending, :completed, :canceled, initial: :pending

        event :complete do
          transitions from: :pending, to: :completed
        end
        event :cancel do
          transitions from: :pending, to: :canceled
        end
        after_transition from: :pending, to: :completed, do: :after_complete
        after_transition from: :pending, to: :canceled, do: :after_cancel
      end

      def after_complete
      end

      def after_cancel
      end
    end
  end
end
