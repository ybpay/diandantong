module Ddt
  # Filter chars that not include in BMP(Basic Multilingual Plane)
  module UnicodeFilter
    extend ActiveSupport::Concern

    included do
      before_validation :filter_special_unicode
    end

    def filter_unicode_columns
      []
    end

    module ClassMethods
      def filter_unicode_for(*column_names)
        define_method :filter_unicode_columns do
          column_names
        end
      end
    end

    def filter_special_unicode
      return if filter_unicode_columns.blank?
      filter_unicode_columns.each do |column_name|
        column_value = self.send column_name
        self.send "#{column_name}=", filter_string(column_value)
      end
    end

    private
      def filter_string(str)
        return str if str.nil?
        cps = str.each_codepoint.select do |cp|
          (0..65535).include? cp
        end
        cps.pack('U*')
      end

  end
end
