#encoding: utf-8
module Ddt
  class VipLevel < Ddt::Base
    attr_accessor :skip_validate_level
    acts_as_paranoid
    replicated_model

    belongs_to :shop, class_name: 'Ddt::Shop', touch: true
    has_many :vip_infos, class_name: 'Ddt::VipInfo'

    validates :level, numericality: { integer: true, greater_than: 0 }, presence: true, unless: :skip_validate_level
    validates :discount, numericality: { greater_than: 0, less_than_or_equal_to: 1.0 }, presence: true
    validates :name, presence: true, uniqueness: { scope: [:shop_id, :deleted_at] }
    validates :upgrade_recharge_money  , numericality: { greater_than_or_equal_to: 0 } , allow_blank: true
    validates :upgrade_total_amount    , numericality: { greater_than_or_equal_to: 0 } , allow_blank: true
    validates :upgrade_get_credits     , numericality: { greater_than_or_equal_to: 0 } , allow_blank: true
    default_scope  {order(discount: :desc, is_default: :desc)}
    scope :auto_upgrade_levels, ->{ where(is_default: false, auto_upgrade: true)}
    scope :base, ->{ where(auto_upgrade: false) }

    before_destroy :validate_users_is_not_empty
    before_destroy :check_default

    def self.default_level
      where(is_default: true).first
    end

    def vip_infos_count
      vip_infos.count
    end

    private
    def validate_users_is_not_empty
      if self.vip_infos.length > 0
        self.errors.add(:base, "不允许删除，因为仍然有会员属于该会员级别，请将该会员级别下的会员转移至其他级别或直接修改本会员级别的信息")
      end
      self.errors.blank?
    end

    def check_default
      self.errors[:base] << '不允许删除默认会员级别' if self.is_default?
    end
  end
end
