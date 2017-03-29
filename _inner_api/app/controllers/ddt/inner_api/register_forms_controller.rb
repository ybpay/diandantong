module Ddt
  module InnerApi
    class RegisterFormsController < InnerApi::BaseController
      def index
        @q = Ddt::RegisterForm.failed.ransack(params[:q])
        @register_forms = @q.result.paginate(page: params[:page], per_page: 100)
      end
    end
  end
end