# encoding: utf-8
module Ddt
  class Lisence < Ddt::Base
    attr_accessor :increment_years

    include Ddt::RechargeRestriction
    acts_as_type(:lisence_type,
      Ddt::Shop::SHOP_TYPES,
      Ddt::Shop::SHOP_TYPES.map{|t| I18n.t("shop.shop_type.#{t}")}
    )

    ### relationships
    belongs_to :agent
    belongs_to :shop

    ### validations
    validates :lisence_no, presence: true
    validates :price, presence: true
    validates :increment_days, presence: true
    validates :lisence_type, presence: true
    validates :agent, presence: true
    validates :branch_num, presence: true
    validates_presence_of :shop, if: :is_used?
    validates_uniqueness_of :lisence_no

    ### callbacks
    before_create :check_agent_privilege
    before_create :check_agent_balance
    before_create :set_branch_num
    after_create :record_purchase_log

    ### scopes
    default_scope -> { order("created_at DESC") }

    def activate(shop)
      if self.is_used?
        raise "This lisence has been used!"
      else
      #  check_shop_applicable(shop)
        check_branch_num_valid(shop)
        transaction do
          self.shop = shop
          self.is_used = true
          self.used_time = Time.now
          self.save!
          note = "代理商 #{self.agent.name} 使用授权许可#{self.lisence_no}(id: #{self.id})为点单通帐号 #{shop.name} 充值"
          record = shop.shop_recharge_records.create!(
            price: self.price,
            increment_days: self.increment_days,
            recharge_type: self.lisence_type,
            lisence_id: self.id,
            agent_id: self.agent.id,
            feature_module_group: self.feature_module_group,
            note: note)
        end
      end
    end

    def self.lisence_type_collection_by_agent(agent)
      if agent.can_sale_multiple_store?
        self.lisence_type_collection
      else
        self.lisence_type_collection.select{|t| t[1] != Ddt::Shop::SHOP_TYPE_MULTIPLE.to_sym}
      end
    end

    def self.generate_lisence_no
      SecureRandom.uuid.to_s.upcase
    end

    def group_name_to_label
     Ddt::FeatureModuleGroup.send(self.feature_module_group)[:label]
    end 

    private
    def set_branch_num
      if %W[mini standard].include? self.lisence_type
        self.branch_num = 1
      elsif 'multiple' == self.lisence_type
        self.branch_num = 100
      end
    end

    def check_agent_privilege
      return if self.lisence_type != 'multiple'
      self.errors.add(:base, '您无权购买该类型的许可') unless self.agent.can_sale_multiple_store?
    end

    def check_agent_balance
      if self.agent.balance < self.price
        self.errors.add(:price, '您的余额不足，请联系点单通进行充值')
        false
      else
        self.note = "购买本授权后，账户余额由#{self.agent.balance}变为#{self.agent.balance - self.price}"
        self.agent.update_column(:balance, self.agent.balance - self.price)
        true
      end
    end

    def check_shop_applicable(shop)
      raise "该点单通帐号不在充值期间内， 不能充值. 注: (只能在过期前一个月为点单通帐号充值)" unless shop.in_recharge_time_range?
      # raise "该许可不能用在该点单通帐号， 许可类型不允许" unless can_apply_to_shop?(shop, self.lisence_type)
    end

    def check_branch_num_valid(shop)
      if self.lisence_type == 'multiple'
        # 对于本来就是本地生活商圈的点单通帐号， 充值门店数等于该点单通帐号的最大门店数
        # 其他的，则升级为基本的100家门店
        self.branch_num = shop.shop_type == 'multiple' ? shop.max_branches_limit : 100
      elsif self.branch_num < shop.max_branches_limit
        raise "该授权码可充值门店数量小于等于#{self.branch_num}的点单通帐号， 该点单通帐号不满足条件"
      end
    end

    def record_purchase_log
      self.agent.agent_logs.create!(log_type: :purchase_lisence, balance_delta: -self.price, description: "购买授权(id: #{self.id})")
    end

  end
end
