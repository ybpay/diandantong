# encoding: utf-8
module Ddt
  class ShopRechargeRecord < Ddt::Base
    attr_accessor :recharge_by
    ### relationships
    include Ddt::BelongsToShop
    include Ddt::RechargeRestriction
    belongs_to :lisence, class_name: 'Ddt::Lisence'
    belongs_to :agent, class_name: 'Ddt::Agent'
    acts_as_type :recharge_type, Ddt::FeatureModuleGroup.all, Ddt::FeatureModuleGroup.all_values.map{|t| t[:label]}
    acts_as_type :recharge_by, [:admin, :agent], %W[管理员 代理]

    ### validations
    validates :shop, presence: true
    validates :increment_days, :recharge_type, :price, :original_price, presence: true
    validates :price, :original_price, :numericality => {:greater_than_or_equal_to => 0}

    ### scopes
    scope :valid, ->{ where("price > 0")}
    validate :validate_upgrade_strategry

    ### callbacks
    before_validation :initialize_charge_column, on: :create
    # before_create :check_shop_applicable
    before_create :assign_branch_num
    before_create :check_agent_balance, if: :agent_id
    after_create :group_to_feature_module_config
    after_create :record_purchase_log, if: :agent_id


    def group_name_to_label
     Ddt::FeatureModuleGroup.send(self.recharge_type)[:label]
    end

    def validate_upgrade_strategry
      unless Ddt::FeatureModuleGroup.can_upgrade_to?(self.shop, self.branch_num, self.recharge_type)
        self.errors.add(:base, "升级策略不允许")
      end
    end

    def group_to_feature_module_config
        shop.upgrade_shop_to(self.recharge_type, self.branch_num, self.ending_time)
    end

    private

    def initialize_charge_column 
      self.beginning_time = [self.shop.expiration_time, DateTime.now].max
      self.ending_time = self.beginning_time + self.increment_days.days
      self.original_price = Ddt::FeatureModuleGroup.price_of_charge_version(self.shop, self.ending_time, self.branch_num, self.recharge_type)
    end

    def check_agent_balance
      if self.agent.balance < self.price
        self.errors.add(:price, '您的余额不足，请联系点单通进行充值')
        false
      else
        self.note = "购买本授权后，账户余额由#{self.agent.balance}变为#{self.agent.balance - self.price}，#{self.note}"
        self.agent.update_column(:balance, self.agent.balance - self.price)
        true
      end
    end

    def record_purchase_log
      self.agent.agent_logs.create!(log_type: :purchase_lisence, balance_delta: -self.price, description: "为客户充值(id: #{self.id})")
    end

    def check_shop_applicable
      if self.agent_id.present?
        raise "该点单通帐号不在充值期间内， 不能充值. 注: (只能在过期前一个月为点单通帐号充值)" unless self.shop.in_recharge_time_range?
        raise "充值非法， 充值类型不允许" unless can_apply_to_shop?(self.shop, self.recharge_type)
      end
    end

    def assign_branch_num
      self.branch_num = self.lisence.branch_num if self.lisence_id.present?
    end

  end
end
