module Ddt
  class CreditsSetting < Ddt::Base

    include Ddt::BelongsToShop
    validates :exchange_radio, numericality: { greater_than: 0 }
  end
end
