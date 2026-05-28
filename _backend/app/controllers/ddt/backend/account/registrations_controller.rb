#encoding: utf-8
class Ddt::Backend::Account::RegistrationsController < Devise::RegistrationsController
  include Ddt::Backend::DeviseUrlHelper
  include Ddt::Backend::SetAgentBrand
  helper_method :can?
  delegate :can?, :authorize!, to: :current_account
  layout false

  # GET /resource/sign_up
  def new
    # we use register_forms
  end

  # POST /resource
  def create
    # we use register_forms
  end

  def edit
  end

  def after_sign_in_path_for(resource)
    get_backend_root_path
  end
end
