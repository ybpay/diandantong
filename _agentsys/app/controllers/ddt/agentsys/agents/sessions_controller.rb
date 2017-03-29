# encoding: utf-8
module Ddt
  class Agentsys::Agents::SessionsController < Devise::SessionsController
    layout 'ddt/layouts/agentsys/agent'

    def after_sign_in_path_for(resource)
      respond_to do |format|
        format.html {
          (stored_location_for(resource) rescue "/") || url_helpers.agentsys_shops_path
        }
        format.json {}
      end
    end

    def after_sign_out_path_for(resource)
      url_helpers.agentsys_root_path
    end
  end
end
