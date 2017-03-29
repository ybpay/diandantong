module Ddt
  module Webpos
    module DeviseUrlHelper
      extend ActiveSupport::Concern
      included do
        helper Ddt::Core::Engine.helpers
        helper Ddt::Webpos::Engine.helpers
        helper Ddt::Core::Engine.routes.url_helpers
        def get_webpos_root_path
          if current_account.nil?
            "/"
          elsif current_account.is_admin?
            "/"
          elsif current_account.is_boss?
            url_helpers.webpos_shop_path(current_account.shop)
          elsif current_account.is_worker?
            url_helpers.webpos_shop_path(current_account.shop)
          else
            url_helpers.webpos_shop_path(current_account.shop)
          end
        end

        def current_account
          current_webpos_webpos_account
        end
      end
    end
  end
end