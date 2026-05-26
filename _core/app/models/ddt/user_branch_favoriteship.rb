module Ddt
  class UserBranchFavoriteship < Ddt::Base

    self.table_name = 'ddt_users_branches_favoriteship'

    belongs_to :followed_user, class_name: "Ddt::BaseUser", counter_cache: :following_branches_count, foreign_key: :base_user_id
    belongs_to :favorite_branch, class_name: "Ddt::Branch", foreign_key: :branch_id
    validates_presence_of :followed_user, :favorite_branch
  end
end
