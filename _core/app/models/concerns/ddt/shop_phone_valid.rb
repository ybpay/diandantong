# encoding:utf-8
module Ddt
  module ShopPhoneValid
    extend ActiveSupport::Concern
    included do
    end

    module ClassMethods
      def valid_phone(*columns)
        columns.each do |column|
          self.class_eval do
            validate "valid_phone_for_#{column}".to_sym
            define_method "valid_phone_for_#{column}".to_sym do
              shop = self.try(:shop) || Ddt::Shop.current
              if shop.present? && shop.is_valid_phone && self.send(column).present? && !(self.send(column) =~ PhoneValidator::REGEXP)
                self.errors[column.to_sym] << "格式错误"
              end
            end
          end
        end
      end
    end
  end
end