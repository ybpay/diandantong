module Ddt
  class PrintSetting < Base

    include BelongsToBranch
    delegate :is_auto_confirm, to: :branch

  end
end