module Ddt
  class Weixin::User::FavoriteBranchesController < WeixinApplicationController
    respond_to :json
    before_action :set_favorite_branch, only: [:create, :destroy]

    def index
      favorite_branches = @current_user.favorite_branches
      @branches = favorite_branches
      render template: 'ddt/weixin/branches/index'
    end

    def create
      begin
        @user_branch_favoriteship = @current_user.user_branch_favoriteships.build(favorite_branch: @favorite_branch)
        @user_branch_favoriteship.save
      rescue
      end
      render json: {}
    end

    def destroy
      @current_user.favorite_branches.destroy(@favorite_branch)
      render json: {}
    end

    private
    def set_favorite_branch
      branch = @current_user.shop.branches.find(params[:id]) rescue nil
      @favorite_branch = in_same_shop(branch) ? branch : nil
    end

    def in_same_shop(branch)
      @current_user.shop == branch.shop
    end

  end
end
