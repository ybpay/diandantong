module Ddt
  module Backend
    module Crm
      class BranchGroupsController < Backend::BaseCrmController
        def index
          @q = @current_shop.branch_groups.ransack(params[:q])
          @branch_groups = @q.result(distinct: true).paginate(page: params[:page])
          render :json => @branch_groups.map(&:select_json)
        end
      end
    end
  end
end