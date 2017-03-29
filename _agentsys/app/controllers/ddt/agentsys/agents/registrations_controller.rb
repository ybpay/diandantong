# encoding: utf-8
module Ddt
  class Agentsys::Agents::RegistrationsController < Devise::RegistrationsController
    layout 'ddt/layouts/agentsys/agent'

    protected
    def after_update_path_for(resource)
      url_helpers.agentsys_profile_path
    end
  end
end
