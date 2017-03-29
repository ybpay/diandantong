module Ddt
  module Webpos
    class FormElementsController < Webpos::BaseController
      def index
        @form_elements = @current_branch.form_elements.with_delivery
        fresh_when(@form_elements)
      end
    end
  end
end