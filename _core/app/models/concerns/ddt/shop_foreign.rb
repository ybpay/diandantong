# encoding:utf-8
module Ddt
  module ShopForeign
    extend ActiveSupport::Concern
    included do
      include ActiveSupport::NumberHelper
    end

    def shop_time_zone
      shop = self.try(:shop) || Ddt::Shop.current
      if shop.present? && shop.enable_foreign?
        shop.time_zone
      else
        "Asia/Shanghai"
      end
    end

    def shop_time_now
      Time.now.in_time_zone(shop_time_zone)
    end

    def shop_today
      Time.now.in_time_zone(shop_time_zone).to_date
    end

    module ClassMethods

      def access_with_shop_time_zone(*attributes)
        set_with_shop_time_zone(*attributes)
        get_with_shop_time_zone(*attributes)
      end

      def set_with_shop_time_zone(*attributes)
        attributes.each do |attribute|
          define_method "#{attribute}=" do |value|
            self.send(:write_attribute, attribute, value)
          end
          define_method "#{attribute}_with_time_zone=" do |value|
            self.send("#{attribute}_without_time_zone=", ActiveSupport::TimeZone[shop_time_zone].parse(value.to_s).try(:in_time_zone))
          end
          alias_method_chain "#{attribute}=", :time_zone
        end
      end

      def get_with_shop_time_zone(*attributes)
        attributes.each do |attribute|
          unless self.instance_methods(false).include?(attribute)
            define_method attribute do
              self.read_attribute(attribute)
            end
          end
          define_method "#{attribute}_with_time_zone" do
            self.send("#{attribute}_without_time_zone").try(:in_time_zone, shop_time_zone)
          end
          alias_method_chain attribute.to_sym, :time_zone
        end
      end

      def with_shop_currency(*methods)
        methods.each do |method|
          define_method "#{method}_in_currency" do
            number_to_currency(self.send(method), unit: self.shop.currency)
          end
        end
      end
    end

    def method_missing(method_name, *args, &block)
      if method_name.to_s =~ /^(.+)_in_currency$/
        self.class.with_shop_currency($1)
        send(method_name, *args, &block)
      else
        super
      end
    end
  end
end