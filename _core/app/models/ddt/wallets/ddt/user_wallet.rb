# encoding: utf-8
module Ddt
  class UserWallet < Ddt::Wallet
    belongs_to :owner, polymorphic: true, touch: true
    delegate :check_auto_upgrade, to: :owner
    validates :amount, numericality:  { greater_than_or_equal_to: 0, less_than: MAX_DECIMAL }
    validates :credits, numericality: { greater_than_or_equal_to: 0, less_than: MAX_INTEGER }

    def send_wallet_change_notify
      wallet_log = self.wallet_logs.order(created_at: :desc).first
      wallet_log.send_change_notify
    end

  end
end
