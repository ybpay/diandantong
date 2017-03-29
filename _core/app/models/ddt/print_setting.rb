module Ddt
  class PrintSetting < Base
    replicated_model

    include BelongsToBranch
    delegate :is_auto_confirm, to: :branch

  end
end