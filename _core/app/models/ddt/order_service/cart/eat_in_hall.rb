module Ddt
  module OrderService
    module Cart
      class EatInHall < Cart::Base
        belongs_to :table
        attr_accessor :guest_num, :table_name, :table_zone_name, :ignore_essentail_product
        def init_info(params={})
          self.table = params.fetch(:table, nil)
          @guest_num = params.fetch(:guest_num, table.try(:guest_num) || 1)
          @guest_num = 1 if @guest_num == 0 || @guest_num.nil?
          @ignore_essential_product = params.fetch(:ignore_essentail_product, false)
          cache_table_info
          ensure_essential_products unless @ignore_essential_product
        end

        def to_options
          super.merge({
            table_id: table_id,
            guest_num: guest_num,
            table_name: table_name,
            table_zone_name: table_zone_name,
          })
        end

        def essential_products
          self.branch.essential_products.eat_in_hall
        end

        def ensure_essential_products
          if self.is_FromWechat? && essential_products.count > 0
            line_items_group_by_itemable = line_items.group_by_itemable
            essential_products.each do |essential_product|
              variant = essential_product.variant
              itemable_line_items = line_items_group_by_itemable.detect{|itemable_line_items| itemable_line_items[:itemable] == variant}
              selected_quantity = itemable_line_items.present? ? itemable_line_items[:line_items].item_count : 0
              essential_quantity = essential_product.essential_quantity(self.guest_num)
              if selected_quantity < essential_quantity
                add(variant, quantity: essential_quantity - selected_quantity)
              end
            end
          end
        end

        concerning :Validation do
          included do
            validate :check_item_count
            validate :check_table
            validate :check_guest_num
            validate :check_essential_products
          end

          def check_table
            if self.table.blank?
              self.errors[:base] << '堂点订单需要桌台'
            elsif self.table.current_order_id.present?
              self.errors[:base] << '当前桌子已经有人下单, 不能下单'
            end
          end

          def check_guest_num
            self.errors[:base] << '堂点订单需要输入客户人数' unless self.guest_num.present? && self.guest_num > 0
          end

          def check_essential_products
            if self.is_FromWechat? && essential_products.count > 0
              line_items_group_by_itemable = line_items.group_by_itemable
              essential_products.each do |essential_product|
                variant = essential_product.variant
                itemable_line_items = line_items_group_by_itemable.detect{|itemable_line_items| itemable_line_items[:itemable] == variant}
                selected_quantity = itemable_line_items.present? ? itemable_line_items[:line_items].item_count : 0
                essential_quantity = essential_product.essential_quantity(self.guest_num)
                if selected_quantity < essential_quantity
                  self.errors[:base] << "#{variant.name}为必选产品，且需要选择至少#{essential_quantity}份，您已选#{selected_quantity}份"
                end
              end
            end
          end
        end

        def update_table_info(params={})
          self.guest_num = params[:guest_num] if params[:guest_num].present?
          if params[:table_id].present?
            self.table_id  = params[:table_id]
            self.table = Ddt::Table.find_by(id: self.table_id)
          end
          cache_table_info
          ensure_essential_products
          true
        end

        def cache_table_info
          if table.present?
            self.table_name      = table.name
            self.table_zone_name = table.table_zone.name
          end
        end

        def table_name_with_zone
          "#{table_zone_name}-#{table_name}"
        end

        concerning :SessionStore do
          included do
            def self.cart_options_from_session(session)
              table = Table.find_by(id: session[:table_id])
              guest_num = session.fetch(:guest_num, 2)
              super.merge({
                table: table,
                guest_num: guest_num
              })
            end
          end

          def to_session
            super.merge({
              table_id: table_id,
              guest_num: guest_num
            })
          end
        end

        concerning :MergeOrderItemable do
          def set_order_itemables_from_table(table)
            line_itemables = table.order_itemables.map(&:to_line_itemable)
            self.table = table
            self.update_line_items(line_itemables)
          end
        end

        def pay_method_blacklist
          [:pay_on_receive, :pay_on_arrive]
        end
      end
    end
  end
end
