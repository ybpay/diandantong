module Ddt
  class TableColor < Ddt::Base

    belongs_to :shop
    validates :shop, presence: true
  end
end
