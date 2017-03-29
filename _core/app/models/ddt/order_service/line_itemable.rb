module Ddt
  module OrderService
    class LineItemable
      attr_accessor :itemable, :itemable_type, :itemable_id, :quantity, :note, :gift, :gift_reason
      def initialize(itemable=nil, params={})
        if itemable.is_a?(Hash)
          params = itemable
          itemable = nil
        end
        params = params.symbolize_keys
        @itemable = itemable.present? ? itemable : params[:itemable]
        if @itemable.present?
          @itemable_type = @itemable.itemable_type
          @itemable_id = @itemable.id
        else
          @itemable_type = params[:itemable_type]
          @itemable_id = params[:itemable_id]
          @itemable = @itemable_type.constantize.find_by(id: @itemable_id) if @itemable_type.present? && @itemable_id.present?
          @itemable_type = @itemable.itemable_type if @itemable.present?
        end
        @quantity = params[:quantity].try(:to_i) || 1
        @note = params[:note] || ""
        @gift = params[:gift].is_a?(String) ? params[:gift] == 'true' : !!params[:gift]
        @gift_reason = params[:gift_reason] || ""
      end

      def valid?
        itemable.present? && quantity > 0
      end


      # argument: [{:itemable_type, :itemable_id, :quantity...}...]
      # return:   [LineItemable...]
      #
      def self.init_list(line_itemable_attribute_array=[])
        line_itemable_attribute_array ||= []
        attr_array = line_itemable_attribute_array.map(&:symbolize_keys)
        hash = attr_array.inject({}){|h, l| h[l[:itemable_type]] ||= []; h[l[:itemable_type]] << l[:itemable_id]; h;}
        itemables = hash.map{|k,v|
          if k == "Ddt::Variant"
            k.constantize.where(id: v).includes(product: [:categories])
          else
            k.constantize.where(id: v)
          end
        }.flatten
        attr_array.each do |item|
          item[:itemable] = itemables.detect{|itemable| item[:itemable_type] == itemable.itemable_type && item[:itemable_id] == itemable.id }
        end
        attr_array.select{|item| item[:itemable].present? }.map{ |p| self.new(p) }.select(&:valid?)
      end

      def to_options
        {
          itemable: itemable,
          itemable_type: itemable_type,
          itemable_id: itemable_id,
          quantity: quantity,
          note: note,
          gift: gift,
          gift_reason: gift_reason
        }
      end

      def gift?
        !!gift
      end

      def can_add_to?(order)
        if ["Ddt::Variant", "Ddt::VariantPackage", "Ddt::ComboPackage"].include?(itemable_type)
          itemable.branch_id == order.branch_id
        else
          true
        end
      end

      concerning :TagItemMethod do
        included do
          def subtotal
            price * quantity
          end
          alias_method :active_quantity, :quantity
          delegate :name, :price, to: :itemable

          def is_combo_package?
            false
          end
        end
      end
    end
  end
end
