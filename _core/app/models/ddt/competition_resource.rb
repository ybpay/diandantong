# encoding:utf-8
module Ddt
  class CompetitionResource < Ddt::Base
    belongs_to :owner, polymorphic: true
    acts_as_type :name, [:order_number, :guest_queue_guest_no]
    # value
  end
end