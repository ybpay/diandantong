module Ddt
  class Calculator < Ddt::Base
    belongs_to :calculable, polymorphic: true

    def compute(computable)
      raise NotImplementedError, "Please implement compute in your calculator: #{self.class.name}"
    end

    # overwrite to provide description for your calculators
    def self.description
      if self.name.include?('Order')
        I18n.t("calculators.order.#{self.name.demodulize.underscore}")
      else
        I18n.t("calculators.line_item.#{self.name.demodulize.underscore}")
      end
    end

    ###################################################################

    def to_s
      self.class.name.titleize.gsub("Calculator\/", "")
    end

    def description
      self.class.description
    end

    def available?(object)
      true
    end
  end
end