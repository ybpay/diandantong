#encoding: utf-8
module Ddt
  class Target < Ddt::Base
    include Ddt::BelongsToBranch
    belongs_to :targetable, polymorphic: true

    def select_json
      {id: self.id, name: self.targetable.name}
    end
  end
end