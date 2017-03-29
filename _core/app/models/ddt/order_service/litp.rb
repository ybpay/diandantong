module Ddt
  module OrderService
    class Litp
      include OrderService::Concern::Base
      belongs_to :itemable, polymorphic: true, with_deleted: true
      attr_accessor :id, :shop_id, :branch_id, :order_id, :line_item_id, :order_change_log_id, :note, :created_at, :name
      attr_accessor :order
      attr_accessor_with_dirty :updated_at, :state, :cook_id
      acts_as_type :state, [:pending, :confirmed, :completed, :canceled], %W[未烹饪 烹饪中 已烹饪 已取消]
      state_machine :state, initial: :pending do
        event :confirm do
          transition from: :pending, to: :confirmed
        end
        event :complete do
          transition from: [:pending,:confirmed], to: :completed
        end
        event :cancel do
          transition from: [:completed,:pending,:confirmed], to: :canceled
        end

        after_transition to: any do |litp|
          litp.save
        end
      end

      def initialize(params={})
        params.each do |key, value|
          self.send("#{key}=", value)
        end
        changes_applied
      end

      [:number, :type, :state, :created_at, :table_id, :table_name, :table_zone_name, :note].each do |key|
        define_method "order_#{key}" do
          order[key]
        end
      end

      def order_table_name_with_zone
        "#{order[:table_zone_name]}-#{order[:table_name]}" if order[:type] == "Ddt::EatInHallOrder"
      end

      def save(options={})
        if self.changed? || options[:touch]
          changes = OrderService::Api::Litp.update(self.id, changed_values)
          apply_changes(changes)
          self
        end
      end

      private
      def apply_changes(changes={})
        self.updated_at = changes[:updated_at]
        changes_applied
      end
    end
  end
end
