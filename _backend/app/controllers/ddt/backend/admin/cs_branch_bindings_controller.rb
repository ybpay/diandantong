# encoding: utf-8
module Ddt
  class Backend::Admin::CsBranchBindingsController < Backend::BaseAdminController
    before_action :set_cs_branch_bindings, only: [:index]


    def index
      @q = @cs_branch_bindings.order(created_at: :desc).ransack(params[:q])
      @cs_branch_bindings = @q.result(distinct: true).paginate(page: params[:page])
    end

    private

    def set_cs_branch_bindings
      if @current_shop.present?
        @cs_branch_bindings = @current_shop.cs_branch_bindings
      else
        @cs_branch_bindings = Ddt::CsBranchBinding.all
      end
    end
  end
end
