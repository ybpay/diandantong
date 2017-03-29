module Ddt
  class BranchTag < Ddt::Tag
    has_many :branches_tags, class_name: 'Ddt::BranchesTag', foreign_key: :tag_id, dependent: :destroy
    has_many :branches, through: :branches_tags, class_name: 'Ddt::Branch'

    def self.skip_validate_branch?
      true
    end
  end
end
