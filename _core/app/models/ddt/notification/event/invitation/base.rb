module Ddt
  class Notification
    module Event
      module Invitation
        class Base < Ddt::NotificationEvent
          belongs_to :branch
          belongs_to_order
          attribute :order_id
          belongs_to :user, class_name: 'Ddt::BaseUser'
          set_from :order
          alias_method :guest, :user

          def inviter
            @inviter ||= order.user
          end
        end
      end
    end
  end
end
