class  Ddt::Backend::Account::SessionsController < Devise::SessionsController
  include Ddt::Backend::DeviseUrlHelper
  include Ddt::Backend::SetAgentBrand
  layout 'ddt/layouts/backend_empty'
  def new
    super
  end

  private
  def after_sign_in_path_for(resource)
    respond_to do |format|
      format.html {
        stored_url = (stored_location_for(resource) rescue "/")
        if stored_url.blank? || stored_url =~ /webpos/
          get_backend_root_path
        else
          stored_url
        end
      }
      format.json {}
    end
  end

  def after_sign_out_path_for(resource)
    url_helpers.root_path
  end

end
