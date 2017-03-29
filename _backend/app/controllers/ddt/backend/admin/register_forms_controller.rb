#encoding: utf-8
module Ddt
  module Backend
    class Admin::RegisterFormsController < Ddt::Backend::BaseAdminController
      def index
        @register_forms = Ddt::RegisterForm.all.paginate(page: params[:page], :per_page => 25)
      end
    end
  end
end