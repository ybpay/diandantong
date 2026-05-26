class ErrorsController < ApplicationController
  include Ddt::Backend::SetAgentBrand
  helper Ddt::Core::Engine.helpers
  helper Ddt::Backend::Engine.helpers
  helper Ddt::Core::Engine.routes.url_helpers
  layout 'ddt/layouts/backend_empty'

  before_action :set_brand



  def file_not_found
    render plain: 'lost', layout: false, status: 404
  end

  def unprocessable
    render plain: 'unprocessable', layout: false, status: 422
  end

  def internal_server_error
    render plain: 'internal_server_error', layout: false, status: 500
  end

  private
    def set_brand
      request_path = request.env["REQUEST_PATH"]
      if request_path =~ /^\/weixin\/shops\/.*/
        shop_slug = request_path.split("/")[3]
        shop = Ddt::Shop.find shop_slug
        if shop.present?
          @oem_brand = shop.is_oem_agent? ? shop.agent_brand : shop.custom_brand_name
        else
          @oem_brand = nil
        end
      else
        set_oem_brand
      end
    end
end
