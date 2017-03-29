#encoding: utf-8
module Ddt
  module Backend
    class Admin::JsErrorsController < Ddt::Backend::BaseAdminController
      def index
        @q = Ddt::JsError.ransack(params[:q])
        @js_errors = @q.result.order(:updated_at => :desc).paginate(page: params[:page], :per_page => 25)
      end

      def show
        @js_error = Ddt::JsError.find(params[:id])
        @js_error_counts = @js_error.js_error_counts.paginate(page: params[:page], :per_page => 25)
      end
    end
  end
end