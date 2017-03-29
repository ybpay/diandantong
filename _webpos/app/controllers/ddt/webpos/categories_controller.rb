module Ddt
  module Webpos
    class CategoriesController < Webpos::BaseController
      def index
        @categories = @current_branch.categories.root.includes(:subs)
        fresh_when(@categories)
      end
    end
  end
end