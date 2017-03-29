module Ddt
  class InvitationOrderGuest < Ddt::Base
    belongs_to_order
    belongs_to :guest, class_name: 'Ddt::User', foreign_key: :guest_id
    belongs_to :agree_guest, class_name: 'Ddt::User', foreign_key: :guest_id
    belongs_to :disagree_guest, class_name: 'Ddt::User', foreign_key: :guest_id

    scope :agree, ->{where(agree: true)}
    scope :disagree, ->{where(agree: false)}

    def accept_invitation
      self.update(agree: true)
      Notification::Event::Invitation::Accepted.create_and_send_notification(order: order, user: guest)
    end

    def reject_invitation
      self.update(agree: false)
      Notification::Event::Invitation::Rejected.create_and_send_notification(order: order, user: guest)
    end

  end
end
