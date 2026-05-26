# encoding: utf-8
module Ddt
  class WalletLog < Ddt::Base
    ### relationships
    include ActiveSupport::NumberHelper
    include Ddt::BelongsToShop
    include Ddt::CacheModel


    cache_model 'Ddt::Branch', with_deleted: true
    belongs_to :branch,    class_name: 'Ddt::Branch'
    delegate :name, to: :branch, prefix: true, allow_nil: true
    belongs_to :wallet,    class_name: 'Ddt::Wallet'
    belongs_to :pay_method,class_name: 'Ddt::PayMethod'
    belongs_to :operator, polymorphic: true
    belongs_to_order
    delegate :owner_name, :of_card?, :of_credits?, to: :wallet
    belongs_to :deduction, class_name: 'Ddt::Deduction', foreign_key: :frozenable_id, foreign_type: :frozenable_type, polymorphic: true
    belongs_to :withdraw, class_name: 'Ddt::Withdraw',  foreign_key: :frozenable_id, foreign_type: :frozenable_type, polymorphic: true

    acts_as_type :reason, [:for_recharge, :for_exchange, :for_clearing,
                           :for_deduction, :for_deduction_complete, :for_deduction_cancel, :for_grant,
                           :for_vip_merge, :for_collection, :for_withdraw, :for_rollback_withdraw,
                           :for_vip_card_pay, :for_rollback_vip_card_pay, :for_import, :for_credits_clear,
                           :for_recharge_refund, :for_recharge_refund_complete, :for_recharge_refund_cancel],
                          %W(充值 兑换 结算 抵扣 抵扣完成 抵扣回退 获得 用户合并 代收款 提款 提款回滚 会员卡支付 回滚会员卡支付 会员导入 积分清零 充值退款 充值退款完成 充值退款回退)

    ### validations
    validates :amount, numericality: { greater_than: -MAX_DECIMAL, less_than: MAX_DECIMAL }, if: :of_card?
    validates :amount, numericality: { greater_than: -MAX_INTEGER, less_than: MAX_INTEGER }, if: :of_credits?

    ### callbacks
    set_from :deduction, targets: [:shop_id, :wallet_id, :order_id]
    set_from :withdraw, targets: [:shop_id, :wallet_id]
    set_shop_from :wallet
    before_validation :set_branch_from_wallet
    before_validation :set_st_time
    before_create :set_balance
    before_create :set_branch_id
    before_create :set_operator_name

    ### scopes
    scope :card, ->{    includes(:wallet).where(ddt_wallets: { type: [Ddt::BranchCardWallet, Ddt::UserCardWallet]}) }
    scope :branch_card, ->{ includes(:wallet).where(ddt_wallets: { type: Ddt::BranchCardWallet})}
    scope :user_card, ->{ includes(:wallet).where(ddt_wallets: { type: Ddt::UserCardWallet})}
    scope :credits, ->{ includes(:wallet).where(ddt_wallets: { type: [Ddt::BranchCreditsWallet, Ddt::UserCreditsWallet]}) }
    default_scope ->{ order(created_at: :desc)}


    def display_amount
      if self.of_credits?
        self.amount.to_i
      else
        self.amount.to_f
      end
    end

    def self.card_reasons
      [:for_recharge, :for_clearing, :for_deduction, :for_deduction_complete, :for_deduction_cancel, :for_vip_merge, :for_recharge_refund, :for_recharge_refund_complete, :for_recharge_refund_cancel]
    end

    def self.branch_card_reasons
      [:for_clearing, :for_deduction_complete, :for_exchange, :for_grant, :for_recharge, :for_recharge_refund_complete]
    end

    def self.user_card_reasons(accessible_by: :branch_manager)

      if accessible_by == :user
        [:for_recharge, :for_deduction, :for_deduction_cancel, :for_vip_merge, :for_vip_card_pay, :for_rollback_vip_card_pay, :for_recharge_refund, :for_recharge_refund_cancel]
      else
        [:for_recharge, :for_deduction, :for_deduction_cancel, :for_vip_merge, :for_import, :for_vip_card_pay, :for_rollback_vip_card_pay, :for_recharge_refund, :for_recharge_refund_cancel]
      end
    end

    def self.credits_reasons
      [:for_exchange, :for_clearing, :for_grant, :for_deduction, :for_deduction_complete, :for_deduction_cancel, :for_vip_merge, :for_recharge_refund, :for_recharge_refund_complete, :for_recharge_refund_cancel]
    end

    def self.branch_credits_reasons
      [:for_clearing, :for_deduction_complete, :for_exchange, :for_grant, :for_recharge_refund_complete]
    end

    def self.user_credits_reasons
      [:for_exchange, :for_grant, :for_deduction, :for_deduction_cancel, :for_user_merge, :for_credits_clear, :for_recharge_refund, :for_recharge_refund_cancel]
    end

    def self.all_reasons
      [:for_recharge, :for_exchange, :for_clearing,
                           :for_deduction, :for_deduction_complete, :for_deduction_cancel, :for_grant,
                           :for_vip_merge, :for_collection, :for_withdraw, :for_rollback_withdraw, :for_vip_card_pay, :for_rollback_vip_card_pay, :for_import,
                           :for_recharge_refund, :for_recharge_refund_complete, :for_recharge_refund_cancel]
    end

    [:card, :branch_card, :user_card, :credits, :branch_credits, :user_credits, :all].each do |name|
      define_singleton_method "#{name}_reason_collection".to_sym do
        self.send("#{name}_reasons").map{|value| [self.reason_name(value),value]}
      end
    end

    def send_change_notify
      user =  self.wallet.owner.base_users.where(type: 'Ddt::User').first
      if user.present?
        if self.of_card?
          Ddt::Notification::Event::User::CardWalletChange.create_and_send_notification(user: user, wallet_log: self)
        elsif self.of_credits?
          Ddt::Notification::Event::User::CreditsWalletChange.create_and_send_notification(user: user, wallet_log: self)
        end
      end
    end

    def branch_name
      return '' if self.branch_id.blank?
      get_branch(self.branch_id).name
    end

    def change_note(note)
      self.note = note
      self.save
    end

    private
    def set_branch_from_wallet
      if self.branch_id.blank? && self.wallet.owner_type == 'Ddt::Branch'
        self.branch_id = self.wallet.owner_id
      end
    end

    def set_balance
      self.balance = wallet.amount
    end

    def set_operator_name
      if operator_id.present?
        case operator
        when Ddt::Account
          self.operator_name = operator.name
        when Ddt::BaseUser
          self.operator_name = "用户自身"
        end
      end
    end

    def set_branch_id
      if order_id.present?
        self.branch_id = self.order.branch_id
      end
    end

    def set_st_time
      if self.st_time.blank?
        self.st_time = Time.now
      end
    end



  end
end
