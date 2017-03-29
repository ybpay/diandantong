class Ddt::Backend::Account::ConfirmationsController < Devise::ConfirmationsController
  include Ddt::Backend::DeviseUrlHelper
  include Ddt::Backend::SetAgentBrand
  layout 'ddt/layouts/account/login'
end