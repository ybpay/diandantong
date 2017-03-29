module Ddt
  class TickAccountItem < Ddt::Base
    include BelongsToBranch
    belongs_to :tick_account
    belongs_to_order
    acts_as_type :state, [:pending, :completed], %W(未结 已结)
    state_machine :state, initial: :pending do
      event :complete do
        transition from: :pending, to: :completed
      end
    end
  end
end