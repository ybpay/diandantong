#encoding: utf-8
module Ddt
  class FeatureModulesConfig < Base
    include BelongsToShopWithTouch
    validates :expired_at, :feature_module, presence: true
    validates_uniqueness_of :feature_module, :scope => :shop_id
    # default_scope ->{ where('expired_at > ?', Time.now) }
    scope :enabled, -> {where(:enabled => true)}
    scope :disabled, -> {where(:enabled => false)}
    scope :available, ->{ where('expired_at > ?', DateTime.now) }
    scope :expired_at_month, -> { where("expired_at > ? and expired_at < ?", DateTime.now, 1.month.from_now)}



    # shop_id
    # feature_module
    # expired_at


    def expired?
      self.expired_at < DateTime.now
    end

    def expired_at_month?
      self.expired_at > DateTime.now && self.expired_at < 1.month.from_now
    end

    def select_json
      m = FeatureModules.get(self.feature_module);
      {
          id:   m[:name],
          name: m[:label]
      }
    end

    def feature_modules_name
      FeatureModules.feature_modules_name(self.feature_module)
    end

  end
end
