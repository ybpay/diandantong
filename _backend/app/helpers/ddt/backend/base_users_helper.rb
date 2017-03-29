# encoding: utf-8
module Ddt
  module Backend
    module BaseUsersHelper
      def base_user_label(base_user, enable_link = true)
        if base_user.present?
          if enable_link
            link_to base_user.to_label, [:backend, base_user.shop, base_user]
          else
            base_user.to_label
          end
        end
      end

    end
  end
end
