module Ddt
  module Backend
    module DeviseUrlHelper
      extend ActiveSupport::Concern
      included do
        helper Ddt::Core::Engine.helpers
        helper Ddt::Backend::Engine.helpers
        helper Ddt::Core::Engine.routes.url_helpers
        def get_backend_root_path
          if current_account.nil?
            Rails.application.default_url_options[:host]
          elsif current_account.is_admin?
            url_helpers.backend_shops_url(host: Rails.application.default_url_options[:host], port: request.port)
          elsif current_account.is_boss? && current_account.last_sign_in_at.nil?
            url_helpers.module_index_backend_shop_url(current_account.shop, host: Rails.application.default_url_options[:host], port: request.port)
          # elsif current_account.is_worker?
          #   url_helpers.backend_shop_orders_path(current_account.shop)
          # elsif current_account.is_boss?
          #   url_helpers.dashboard_backend_shop_path(current_account.shop)
          # elsif current_account.is_deliveryman?
          #   url_helpers.assigned_backend_shop_delivery_orders_path(current_account.shop)
          # else
          #   url_helpers.backend_shop_branches_path(current_account.shop)
          # end
          else
            url_helpers.dashboard_backend_shop_url(current_account.shop, host: Rails.application.default_url_options[:host], port: request.port)
          end
        end
      end
    end
  end
end