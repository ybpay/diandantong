module Ddt
  module OrderService
    module Cart
      class Delivery < Cart::Base
        attr_accessor :shipment,
                      :shipment_total, :shipment_state,
                      :delivery_name, :delivery_phone, :delivery_address,
                      :delivery_zone_name, :delivery_date, :delivery_time_display,
                      :latitude, :longitude
        attr_accessor :is_free_shipment
        def init_info(params={})
          ensure_essential_products
          @shipment = params.fetch(:shipment, @branch.default_shipment)
          @shipment.shop = self.shop
          @shipment.branch = self.branch
          @shipment.delivery_zone ||= branch.delivery_setting.default_delivery_zone
          @shipment.delivery_date ||= branch.delivery_setting.default_delivery_date
          @shipment.delivery_time ||= branch.delivery_setting.default_delivery_time
          @shipment.calculate_cost(cart: self)
          cache_shipment_info
        end

        def after_place(order, operator)
          shipment.order = order
          shipment.save!
          super
        end

        def free_shipment
          self.shipment_total = 0.0
          self.is_free_shipment = true
        end

        def is_today_delivery?(date=nil)
          date = date || delivery_date || Date.current
          if date.class == String
            params = date.split('-').map{ |d| d.to_i }
            date = Date.new(*params)
          end
          TimeUtil.is_same_day?(date.in_time_zone(self.shop.time_zone), Date.current.in_time_zone(self.shop.time_zone))
        end

        def to_options
          options = {}
          [ :delivery_name, :delivery_phone, :delivery_address,
            :delivery_zone_name, :delivery_date, :delivery_time_display,
            :shipment_total, :shipment_state, :latitude, :longitude ].each{|key| options[key] = self.send(key)}
          super.merge(options)
        end

        concerning :SessionStore do
          included do
            def self.cart_options_from_session(session)
              address = Address.find_by(id: session[:shipment_address_id])
              delivery_zone = DeliveryZone.find_by(id: session[:shipment_delivery_zone_id])
              delivery_time = DeliveryTime.find_by(id: session[:shipment_delivery_time_id])
              delivery_date = session[:shipment_delivery_date].present? ? Date.parse(session[:shipment_delivery_date]) : Date.today
              delivery_date = Date.today if delivery_date < Date.today
              shipment = Shipment.new(
                address: address,
                delivery_zone: delivery_zone,
                delivery_time: delivery_time,
                delivery_date: delivery_date
              )
              super.merge({
                shipment: shipment
              })
            end
          end

          def to_session
            super.merge({
              shipment_address_id: shipment.address_id,
              shipment_delivery_zone_id: shipment.delivery_zone_id,
              shipment_delivery_time_id: shipment.delivery_time_id,
              shipment_delivery_date: shipment.delivery_date.try(:strftime, "%F"),
            })
          end
        end

        def update_shipment(params={})
          shipment.delivery_zone_id = params[:delivery_zone_id] if params[:delivery_zone_id].present?
          shipment.address_id       = params[:address_id]       if params[:address_id].present?
          shipment.delivery_time_id = params[:delivery_time_id] if params[:delivery_time_id].present?
          shipment.delivery_date    = params[:delivery_date]    if params[:delivery_date].present?
          shipment.calculate_cost(cart: self)
          cache_shipment_info
        end

        def essential_products
          self.branch.essential_products.delivery
        end

        def ensure_essential_products
          if self.is_FromWechat? && essential_products.count > 0
            line_items_group_by_itemable = line_items.group_by_itemable
            essential_products.each do |essential_product|
              variant = essential_product.variant
              itemable_line_items = line_items_group_by_itemable.detect{|itemable_line_items| itemable_line_items[:itemable] == variant}
              selected_quantity = itemable_line_items.present? ? itemable_line_items[:line_items].item_count : 0
              essential_quantity = essential_product.essential_quantity
              if selected_quantity < essential_quantity
                add(variant, quantity: essential_quantity - selected_quantity)
              end
            end
          end
        end

        concerning :Validation do
          included do
            validate :check_item_count
            validate :check_essential_products
          end

          def check_essential_products
            if self.is_FromWechat? && essential_products.count > 0
              line_items_group_by_itemable = line_items.group_by_itemable
              essential_products.each do |essential_product|
                variant = essential_product.variant
                itemable_line_items = line_items_group_by_itemable.detect{|itemable_line_items| itemable_line_items[:itemable] == variant}
                selected_quantity = itemable_line_items.present? ? itemable_line_items[:line_items].item_count : 0
                essential_quantity = essential_product.essential_quantity
                if selected_quantity < essential_quantity
                  self.errors[:base] << "#{variant.name}为必选产品，且需要选择至少#{essential_quantity}份，您已选#{selected_quantity}份"
                end
              end
            end
          end
        end



        def pay_method_blacklist
          [:pay_on_arrive]
        end

        private
        def default_pay_method
          "pay_on_receive"
        end

        def cache_shipment_info
          self.delivery_name         = shipment.name
          self.delivery_phone        = shipment.phone
          self.delivery_address      = shipment.content
          self.delivery_zone_name    = shipment.delivery_zone_name
          self.delivery_date         = shipment.delivery_date
          self.delivery_time_display = shipment.delivery_time_display
          self.shipment_total        = shipment.cost  unless is_free_shipment
          self.shipment_state        = shipment.state
          self.latitude              = shipment.latitude
          self.longitude             = shipment.longitude
        end

        alias_method :extra_amount, :shipment_total
      end
    end
  end
end