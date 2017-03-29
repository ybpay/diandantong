# encoding:utf-8
module Ddt
  module Frozenable
    extend ActiveSupport::Concern
    included do
      acts_as_type :state, [:pending, :completed, :canceled], %W(已冻结 已完成 已回滚)
      state_machine :state, initial: :pending do
        event :complete do
          transition from: :pending, to: :completed
        end
        event :cancel do
          transition from: :pending, to: :canceled
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
