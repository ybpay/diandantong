#encoding: utf-8
module Ddt
  class BranchGroup < Ddt::Base
    belongs_to :shop, class_name: 'Ddt::Shop', touch: true
    has_and_belongs_to_many :branches, class_name: 'Ddt::Branch', :join_table => 'ddt_branches_branch_groups'
    validates_presence_of :name
    validates_uniqueness_of :name, allow_blank: false, scope: :shop_id
    ids_string_for :branches

    def select_json
      {id: id, name: name, text: name }
    end
  end
end
