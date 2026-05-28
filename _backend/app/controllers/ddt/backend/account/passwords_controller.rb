class Ddt::Backend::Account::PasswordsController < Devise::PasswordsController
  include Ddt::Backend::DeviseUrlHelper
  include Ddt::Backend::SetAgentBrand
  layout false
  private
  def after_sign_in_path_for(resource)
    get_backend_root_path
  end
end