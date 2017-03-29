module Ddt
  module Calculable
    extend ActiveSupport::Concern

    included do
      has_one :calculator, class_name: "Ddt::Calculator", as: :calculable, inverse_of: :calculable, dependent: :destroy, autosave: true
      accepts_nested_attributes_for :calculator
      validates :calculator, presence: true

      def self.calculators
        ddt_calculators.send model_name_without_ddt_namespace
      end

      def calculator_type
        calculator.class.to_s if calculator
      end

      def calculator_type=(calculator_type)
        klass = calculator_type.constantize if calculator_type
        self.calculator = klass.new if klass && !self.calculator.is_a?(klass)
      end

      private
      def self.model_name_without_ddt_namespace
        self.to_s.tableize.gsub('/', '_').sub('ddt_', '')
      end

      def self.ddt_calculators
        Rails.application.config.ddt.calculators
      end
    end
  end
end