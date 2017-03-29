module Ddt
  module CommonApi
    module V1
      class ShopsController < V1::BaseController
        def show
          render :show
        end
      end
    end
  end
end
