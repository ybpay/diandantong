# encoding:utf-8
module Ddt
  class Promotion < Ddt::Base
    include BelongsToShopWithTouch

    acts_as_type :match_policy, [:match_all, :match_any], %W[全部匹配 至少匹配一个]
    acts_as_type :branch_scope_policy, [:match_all_branches, :match_part_branches], %W[适用于所有门店 适用于部分门店]
    # relationships
    # 如果是属于shop的promotion这里的branch关联为空
    belongs_to :branch, class_name: 'Ddt::Branch'
    has_many :promotion_rules, autosave: true, dependent: :destroy, class_name: 'Ddt::PromotionRule', foreign_key: :promotion_id
    alias_method :rules, :promotion_rules
    has_many :promotion_actions, autosave: true, dependent: :destroy, class_name: 'Ddt::PromotionAction', foreign_key: :promotion_id
    alias_method :actions, :promotion_actions
    accepts_nested_attributes_for :promotion_actions, :promotion_rules

    has_and_belongs_to_many :branches, join_table: 'ddt_promotions_branches', class_name: 'Ddt::Branch'
    ids_string_for :branches

    include Ddt::Attachable
    attachable_one :image, variants: { medium: [720, 270], thumb: [180, 67] }

    access_with_shop_time_zone :starts_at, :expires_at
    scope :of_show_on_index, -> { where(:show_on_index => true)}

    # validations
    validates_presence_of :name, :description, :keywords
    validates :usage_limit, numericality: { greater_than: 0, allow_nil: true }
    validates :image, file_size: { maximum: 0.5.megabytes.to_i } , if: :image?
    before_destroy :touch_related_branches
    after_save :touch_related_branches

    # callbacks
    set_shop_from :branch

    # scope
    scope :active, -> {
      weekday_key =
        case Time.now.wday
        when 0; :enable_on_sunday;
        when 1; :enable_on_monday;
        when 2; :enable_on_tuesday;
        when 3; :enable_on_wednesday;
        when 4; :enable_on_thursday;
        when 5; :enable_on_friday;
        when 6; :enable_on_saturday;
        end
      where('starts_at IS NULL OR starts_at < ?', Time.now)
        .where('expires_at IS NULL OR expires_at > ?', Time.now)
        .where(weekday_key => true)
    }
    scope :in_shop, -> { where(branch_id: nil)}
    scope :in_branch, -> { where.not(branch_id: nil)}
    # for shop promotion filter branch
    scope :active_in_branch, ->(branch){
      includes(:branches).where("ddt_promotions.branch_scope_policy = 'match_all_branches' OR ddt_branches.id = ?", branch.id).references("ddt_branches")
    }

    def in_shop?
      branch_id.nil?
    end

    def in_branch?
      !in_shop?
    end

    # def rules
    #   rules = []
    #   rules.concat(TCC.fetch("shop.#{shop.id}.promotion_rules"){shop.promotion_rules})
    #   if branch.present?
    #     rules.concat(TCC.fetch("branch.#{branch.id}.promotion_rules"){branch.promotion_rules})
    #   end
    #   rules.select{|it|it.promotion_id == self.id}
    # end

    # def actions
    #   actions = []
    #   actions.concat(TCC.fetch("shop.#{shop_id}.promotion_actions"){shop.promotion_actions})
    #   if branch.present?
    #     actions.concat(TCC.fetch("branch.#{branch.id}.promotion_actions"){branch.promotion_actions})
    #   end
    #   actions.select{|it|it.promotion_id == self.id}
    # end

    def eligible?(promotable)
      return false if expired?
      return false if usage_limit_exceeded?(promotable)
      eligible_rules(promotable).present?
    end

    def expired?
      ( starts_at.present? && Time.now < starts_at) ||
      (expires_at.present? && Time.now > expires_at)
    end

    # eligible rules array
    def eligible_rules(promotable)
      if rules.present?
        results = rules.select{|rule| rule.applicable?(promotable) && rule.eligible?(promotable)}
        if (self.is_match_all? && (results.count == rules.count)) ||
           (self.is_match_any? && results.count > 0 )
          results
        end
      end
    end

    def usage_limit_exceeded?(promotable)
      raise NotImplementedError, "usage_limit_exceeded? should be implemented in (#{self.class.name}) sub-class of Promotion"
    end

    def activate(promotable)
      raise NotImplementedError, "activate should be implemented in (#{self.class.name}) sub-class of Promotion"
    end

    def used_by?(user, options={})
      raise NotImplementedError, "used_by? should be implemented in (#{self.class.name}) sub-class of Promotion"
    end

    def active_branches
      if self.in_shop?
        if self.is_match_all_branches?
          self.shop.branches
        else
          self.branches
        end
      else
        [self.branch].compact
      end
    end

    def usable_in_all_branches
      self.in_shop? && self.is_match_all_branches?
    end

    def active_branches_label
      if usable_in_all_branches
        '所有门店'
      else
        self.active_branches.map(&:name).join(',')
      end
    end

    def weixin_show_path
      "weixin/shops/#{self.shop_id}?_ng_path=/promotions/#{self.id}"
    end
    url_method_for :weixin_show

    private
    def touch_related_branches
      if usable_in_all_branches
        # touch all branches
        Ddt::Branch.where(id: self.shop.try(:branch_ids)).update_all(updated_at: Time.now())
      else
        # touch related branches
        Ddt::Branch.where(id: self.branch_ids).update_all(updated_at: Time.now())
      end
    end
  end
end
