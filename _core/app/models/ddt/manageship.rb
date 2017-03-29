module Ddt
  class Manageship < Ddt::Base
    belongs_to :account, class_name: 'Ddt::Account'
    belongs_to :branch, class_name: 'Ddt::Branch'
    validates :account, presence: true
    validates :branch_id, presence: true, uniqueness: {:scope => :account_id}

  end
end
