module Ddt
  class BranchesTag < Ddt::Base
    belongs_to :branch, class_name: 'Ddt::Branch', touch: true
    belongs_to :tag, class_name: 'Ddt::BranchTag',counter_cache: :count
  end
end
