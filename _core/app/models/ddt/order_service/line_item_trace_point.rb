module Ddt
  module OrderService
    class LineItemTracePoint
      include OrderService::Concern::Base
      include OrderService::Concern::BelongsToOrder
      include AASM
      belongs_to :itemable, polymorphic: true, with_deleted: true
      attr_accessor_with_dirty :id, :line_item_id, :order_change_log_id, :note, :created_at, :updated_at, :name, :state, :cook_id
      acts_as_type :state, [:pending, :confirmed, :completed, :canceled], %W[未烹饪 烹饪中 已烹饪 已取消]
      aasm column: :state do
        state :pending, :confirmed, :completed, :canceled, initial: :pending

        event :confirm do
          transitions from: :pending, to: :confirmed
        end
        event :complete do
          transitions from: [:pending, :confirmed], to: :completed
        end
        event :cancel do
          transitions from: [:completed, :pending, :confirmed], to: :canceled
        end
      end

      def initialize(params={})
        super
        set_timestamps if new?
        changes_applied if exists?
      end

      def in_white_list?(while_list_ids)
        # todo cache product_id in db
        while_list_ids.include? itemable.product_id
      end

      def line_item
        @line_item ||= self.order.line_items.detect{|line_item| line_item.id == self.line_item_id }
      end
      delegate :price, to: :line_item, prefix: true
    end
  end
end
