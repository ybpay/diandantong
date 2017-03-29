module Ddt
  module OrderService
    module Concern
      module BelongsToOrder
        extend ActiveSupport::Concern
        included do
          delegate :shop, :branch, :shop_id, :branch_id, to: :order
          alias_method :cart, :order
          alias_method :cart=, :order=
          attr_accessor_with_dirty :_destroy, :order_id
          alias_method :destroyed?, :_destroy
        end

        def initialize(params={})
          self.order = params[:order] || params[:cart]
          params.except(:shop_id, :branch_id, :order_id, :order, :cart).each do |key, value|
            self.send("#{key}=", value) rescue nil
          end
        end

        def order
          @order
        end

        def order=(order)
          @order = order
          self.order_id = order.try(:id)
        end

        def destroy
          if self.new?
            self.delete
          else
            self._destroy = true
          end
        end

        def delete
          self.order.send(self.class.name.demodulize.underscore.pluralize).delete(self)
        end

        def recover
          self._destroy = nil
        end

        def update(params={})
          params.each do |key, value|
            self.send("#{key}=", value)
          end
        end

        def apply_change(change={})
          if exists?
            if self.id == change[:id]
              self.created_at = change[:created_at]
              self.updated_at = change[:updated_at]
            end
          else
            self.id = change[:id]
            self.created_at = change[:created_at]
            self.updated_at = change[:updated_at]
          end
          changes_applied
        end

        def to_param
          id
        end

        def set_timestamps
          self.created_at = current_time
          self.updated_at = current_time
        end
      end
    end
  end
end
