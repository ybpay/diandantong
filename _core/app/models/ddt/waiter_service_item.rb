module Ddt
  class WaiterServiceItem < Base
    replicated_model

    include BelongsToBranchWithTouch
    validates_presence_of :name
  end
end