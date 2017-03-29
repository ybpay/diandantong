module Ddt
  class TableColor < Ddt::Base
    replicated_model

    belongs_to :shop
    validates :shop, presence: true
  end
end
