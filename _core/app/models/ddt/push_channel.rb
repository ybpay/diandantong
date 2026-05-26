module Ddt
    class PushChannel < Ddt::Base

        belongs_to :account, class_name: 'Ddt::Account'
        default_scope -> {where('expired_at is null or expired_at > NOW()').order("created_at DESC")}
        scope :active, -> {where('updated_at > DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 7 DAY)')}
        validates_presence_of :account_id, :j_push_channel_id, :os_type

        def expire_it
            self.update_attribute(:expired_at, Time.now)
        end
    end
end
