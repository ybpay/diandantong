module Ddt
  class KitchenSetting < Ddt::Base

    include BelongsToBranch

    validates :warning_wait_minitue, numericality: { greater_than: 0 }

  end
end
