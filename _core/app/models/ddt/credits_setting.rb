module Ddt
  class CreditsSetting < Ddt::Base
    replicated_model

    include Ddt::BelongsToShop
    validates :exchange_radio, numericality: { greater_than: 0 }
  end
end
