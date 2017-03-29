module Ddt
  class LineItem < ActiveRecord::Base
    belongs_to :itemable, polymorphic: true
  end
end