module Ddt
  class TickAccount < Ddt::Base
    acts_as_paranoid
    include BelongsToBranch
    has_many :tick_account_items
    alias_method :items, :tick_account_items
    validates_presence_of :name
    scope :enable, ->{ where(enable: true)}

    def select_json
      { id: id, name: name }
    end
  end
end