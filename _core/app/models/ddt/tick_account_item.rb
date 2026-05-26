module Ddt
  class TickAccountItem < Ddt::Base
    include BelongsToBranch
    include AASM
    belongs_to :tick_account
    belongs_to_order
    acts_as_type :state, [:pending, :completed], %W(未结 已结)
    aasm column: :state do
      state :pending, :completed, initial: :pending

      event :complete do
        transitions from: :pending, to: :completed
      end
    end
  end
end