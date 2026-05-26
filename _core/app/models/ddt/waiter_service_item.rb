module Ddt
  class WaiterServiceItem < Base

    include BelongsToBranchWithTouch
    validates_presence_of :name
  end
end