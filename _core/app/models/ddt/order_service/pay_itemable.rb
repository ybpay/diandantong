module Ddt
  module OrderService
    class PayItemable
      attr_accessor :pay_method, :pay_method_id, :pay_method_name_sym, :amount, :shop, :tick_account_id, :tick_account
      def initialize(params={})
        @shop = params.fetch(:shop, nil)
        @pay_method = params.fetch(:pay_method, nil)
        @pay_method_id = params[:id] || params[:pay_method_id]
        if @pay_method_id.present? && @pay_method.blank?
          @pay_method = @shop.pay_methods.find_by(id: @pay_method_id)
        end
        @pay_method_name_sym = params[:pay_method_name_sym] || params[:name_sym]
        @amount = params.fetch(:amount).to_f
        if @pay_method.nil? && @pay_method_name_sym.present?
          @pay_method = @shop.pay_methods.builtin.find_by(name_sym: @pay_method_name_sym) if PayMethod.builtin_names.include?(@pay_method_name_sym.to_sym)
        else
          @pay_method_name_sym = @pay_method.name_sym
        end
        @tick_account_id = params[:tick_account_id]
        @tick_account = TickAccount.find_by(id: params[:tick_account_id]) if @tick_account_id.present?
      end

      def valid?
        pay_method.present? && (amount >= 0 || pay_method.enable_negative?) && ( pay_method_name_sym.try(:to_sym) != :tick_for_account || tick_account.present? )
      end

      def self.init_list(pay_itemable_attribute_array=[], shop:)
        attr_array = pay_itemable_attribute_array.map(&:symbolize_keys)
        attr_array.map{ |p| self.new(p.merge(shop: shop)) }.select(&:valid?)
      end

      def to_options
        {
          pay_method: pay_method,
          pay_method_name_sym: pay_method_name_sym,
          amount: amount,
          tick_account: tick_account,
        }
      end
    end
  end
end