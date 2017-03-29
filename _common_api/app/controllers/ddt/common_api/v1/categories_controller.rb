module Ddt
  module CommonApi
    module V1
      class CategoriesController < V1::BaseController
        def index
          @categories = @current_branch.categories.root.includes(:subs).ransack(params[:q]).result
          fresh_when(@categories)
        end
      end
    end
  end
end
