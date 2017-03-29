module Ddt
  class PrintTime < Ddt::Base
    validate :order_id, presence: true, uniqueness: true
  end 
end