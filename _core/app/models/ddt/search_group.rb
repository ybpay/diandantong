module Ddt
  class SearchGroup < Ddt::Base
    include Ddt::BelongsToBranch

    validates_presence_of :name

    # preference
  end
end