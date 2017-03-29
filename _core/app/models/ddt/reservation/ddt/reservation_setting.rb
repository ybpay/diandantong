# encoding: utf-8
module Ddt
  class ReservationSetting < Ddt::Base
    include BelongsToBranchWithTouch
    replicated_model

    validates_presence_of :average_consumption, :prepayment_type, :max_reservation_days
    validates :max_reservation_days, numericality: { greater_than_or_equal_to: 1}

    acts_as_type :prepayment_type, [:only_table, :only_order, :table_or_order], %W[只订座  提前点餐 订座或者提前点餐]

  end
end
