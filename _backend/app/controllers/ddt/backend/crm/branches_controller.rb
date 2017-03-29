module Ddt
  module Backend
    module Crm
      class BranchesController < Backend::BaseCrmController
        def index
          @q = managed_branches.ransack(params[:q])
          @branches = @q.result(distinct: true).paginate(page: params[:page])
          render :json => @branches.map(&:select_json)
        end
      end
    end
  end
end