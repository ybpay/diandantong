# encoding: utf-8
module Ddt
  class DeliveryRange < Ddt::Base
    include Ddt::BelongsToBranch
    replicated_model


    before_validation :ensure_not_nil
    validates_presence_of :start_at, :end_at
    validate :start_at_not_grater_than_end_at
    validate :can_not_overlap
    validates :start_at, :end_at, :numericality => {grater_than_or_equal_to: 0, only_integer: true}
    after_save :update_branch_min_delivery_fee


    def self.get_distance_cost(delivery_ranges, distance)
      delivery_ranges.each do |delivery_range|
        return delivery_range.cost if delivery_range.include? distance
      end
      0
    end

    def include?(distance)
      (start_at...end_at).include? distance
    end

    def overlaps?(other)
      (start_at...end_at).overlaps?(other.start_at...other.end_at)
    end

    def range_label
      "#{start_at}km - #{end_at}km"
    end

    private
      def ensure_not_nil
        if start_at.nil?
          self.errors.add(:start_at, "不能为空")
          return false
        end
        if end_at.nil?
          self.errors.add(:end_at, "不能为空")
          return false
        end
        return true
      end

      def start_at_not_grater_than_end_at
        self.errors.add(:start_at, "不能大于结束值") if start_at > end_at
      end

      def can_not_overlap
        branch.delivery_ranges.each do |delivery_range|
          next if self.id && self.id == delivery_range.id
          if delivery_range.overlaps?(self)
            self.errors[:base] << "您填写的范围不能与范围( #{delivery_range.range_label} )发生重叠"
          end
        end
      end

      def update_branch_min_delivery_fee
        self.branch.delivery_setting.update_column(:min_delivery_fee, self.branch.delivery_ranges(:reload).map(&:cost).min)
      end

  end
end
