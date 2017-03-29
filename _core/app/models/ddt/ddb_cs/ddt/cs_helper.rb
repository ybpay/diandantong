module Ddt
  class CsHelper
    include ActiveModel::Validations
    attr_accessor :branch_id, :start_at, :end_at
    DATE_TIME_REGEX = /\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/

    validates_presence_of :branch_id, :start_at, :end_at
    validates_format_of :start_at, with: DATE_TIME_REGEX, message: '正确格式应为(%Y-%m-%d %H:%H:%H)'
    validates_format_of :end_at,   with: DATE_TIME_REGEX, message: '正确格式应为(%Y-%m-%d %H:%H:%H)'

    def initialize(branch_id:, start_at:, end_at:)
      @branch_id = branch_id
      @start_at  = start_at
      @end_at    = end_at
    end

    def perform
      # self.class.update_data(branch_id, start_at, end_at)
      Ddt::CsDataUpdateWorker.perform_in(1.second, branch_id, start_at, end_at)
    end

    class << self
      def update_data(branch_id, start_at, end_at)
        branch = Ddt::Branch.find branch_id
        start_at = Time.parse(start_at)
        end_at = Time.parse(end_at)
        fix_order_ext(branch, start_at, end_at)
        fix_not_actual_amount(branch, start_at, end_at)
        fix_shift(branch, start_at, end_at)
      end

      def fix_not_actual_amount(branch, start_at, end_at)
        branch.orders.includes(:pay_items, :line_items).where(paid_at: start_at..end_at).each do |order|
          order.pay_items.each do |pay_item|
            pay_item.update(not_actual_amount: pay_item.get_not_actual_amount)
          end
          order.update_line_item_not_actual_amount
          order.update_combo_package_item_adjustments
          order.save
        end
      end

      def fix_shift(branch, start_at, end_at)
        shifts = branch.shifts.closed.where(created_at: start_at..end_at)
        if shifts.present?
          shifts.each do |shift|
            shift.update_amount
          end
        end
      end

      def fix_order_ext(branch, start_at, end_at)
        branch.orders.includes_none.where(paid_at: start_at..end_at).each do |order|
          order.create_order_ext if order.order_ext.blank?
        end
      end

      def has_cs_order?(branch, start_at, end_at)
        branch.orders.where(paid_at: start_at..end_at, number_start: 'L').count > 0
      end
    end


  end
end
