module Ddt
  class StateChange < Ddt::Base
    belongs_to :stateful, polymorphic: true
    belongs_to :operator, polymorphic: true
    validates_presence_of :state_name, :previous_state, :next_state
    delegate :shop, to: :stateful
  end
end