class Ddt::Backend::Account::UnlocksController < Devise::UnlocksController
  include Ddt::Backend::DeviseUrlHelper
  include Ddt::Backend::SetAgentBrand
  layout 'ddt/layouts/backend_empty'

  protected

    def after_sending_unlock_instructions_path_for(resource)
      get_backend_root_path
    end

    def after_unlock_path_for(resource)
      get_backend_root_path
    end

end