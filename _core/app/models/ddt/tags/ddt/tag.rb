module Ddt
  class Tag < Ddt::Base
    include BelongsToBranch

    validates_presence_of :name

    acts_as_type :type, ['Ddt::ProductTag', 'Ddt::ItemNoteTag', 'Ddt::BranchTag'], %W[产品标签 品注标签 门店标签]

    def select_json
      { id: self.id, text: self.name }
    end

    def tag_json
      { id: self.name, text: self.name }
    end

  end
end
