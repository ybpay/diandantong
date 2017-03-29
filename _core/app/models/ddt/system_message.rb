module Ddt
  class SystemMessage < Ddt::DdtEx
    
    include BelongsToShop
    belongs_to :account
    set_shop_from :account
    acts_as_type :message_type, [:exception], %w[异常消息]
    default_scope ->{ order(created_at: :desc) }
    after_create :increment_msg_count
    scope :of_unread, -> {where(:is_read => false)}

    def self.send_to_shop(shop_id, type, content)
      shop = Ddt::Shop.find(shop_id)
      shop.accounts.boss.each do |account|
        self.send_to_account(account.id, type, content)
      end
    end

    def self.send_to_account(account_id, type, content)
      account = Ddt::Account.find(account_id)
      shop = account.shop
      message = account.system_messages.create(message_type: type, content: content)
      Notification::Event::Account::SendMessage.create_and_send_notification(system_message: message)
    end

    def change_to_read
      self.is_read = true
      self.save!
      self.account.reset_msg_count
    end

    private
    def increment_msg_count
      self.account.reset_msg_count
    end
  end
end