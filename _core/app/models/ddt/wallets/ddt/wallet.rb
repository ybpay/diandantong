# encoding: utf-8
module Ddt
  class Wallet < Ddt::Base
    include Discard::Model
    default_scope { kept }

    ### relationships
    include ActiveSupport::NumberHelper
    include Ddt::BelongsToShop
    belongs_to :owner, polymorphic: true
    has_many :wallet_logs, class_name: 'Ddt::WalletLog', dependent: :destroy
    alias_method :logs, :wallet_logs

    ### validations
    validates :owner, presence: true

    ### callbacks
    set_shop_from :owner

    def owner_with_discarded
      if self.owner_type && self.owner_id
        self.owner_type.constantize.with_discarded.find(self.owner_id)
      end
    end
    alias_method :owner_without_deleted, :owner
    alias_method :owner, :owner_with_deleted
    def of_credits?
      %W[Ddt::BranchCreditsWallet Ddt::UserCreditsWallet Ddt::ShopCreditsWallet].include? self.type
    end

    def of_card?
      %W[Ddt::BranchCardWallet Ddt::UserCardWallet Ddt::ShopCardWallet].include? self.type
    end

    def of_branch?
      %W[Ddt::BranchCardWallet Ddt::BranchCreditsWallet].include? self.type
    end

    def of_user?
      %W[Ddt::UserCardWallet Ddt::UserCreditsWallet].include? self.type
    end

    def owner_name
      self.of_branch? ? self.owner.try(:name) : self.owner.try(:to_label)
    end

    def amount_name
      self.of_card? ? '余额' : '积分'
    end

    def display_amount
      self.of_card? ? self.amount_in_currency : self.amount.to_i
    end

  end
end
