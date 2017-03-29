module Ddt
  module ActsAsModule
    extend ActiveSupport::Concern
    included do
      validates_presence_of :expired_at
    end

    module ClassMethods
    end

    def is_available?
      self.enable? && !self.expired?
    end

    def expired?
      self.expired_at < DateTime.now
    end

    def enable_name
      self.enable? ? I18n.t("enabled") : I18n.t("disabled")
    end
  end
end