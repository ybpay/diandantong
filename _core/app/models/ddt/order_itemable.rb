module Ddt
  class OrderItemable < Ddt::Base
    include BelongsToBranch
    belongs_to :user, class_name: 'Ddt::BaseUser', foreign_key: :base_user_id
    belongs_to :itemable, polymorphic: true
    belongs_to :guest_queue, class_name: 'Ddt::GuestQueue'
    validates :quantity, numericality: { greater_than: 0}
    acts_as_type :store_type, [:for_pre_order, :for_merge_order, :for_wifi_order], %W(预点菜 拼单 wifi堂点)
    scope :for_pre_order, ->{ where(store_type: :for_pre_order) }
    scope :for_merge_order, ->{ where(store_type: :for_merge_order) }
    scope :for_wifi_order, ->{ where(store_type: :for_wifi_order) }
    scope :of_user, ->(user){ where(base_user_id: user.id)}
    belongs_to :table

    delegate :name, :price, to: :itemable

    def name_with_note
      "#{name} #{note.present? ? "[#{note}]" : ""}"
    end

    def amount
      price * quantity
    end

    def plus
      self.with_lock do
        self.quantity += 1
        self.save
      end
    end

    def minus
      self.with_lock do
        self.quantity -= 1
        self.quantity > 0 ? save : destroy
      end
    end

    def to_line_itemable
      OrderService::LineItemable.new(itemable, quantity: quantity, note: note)
    end

    class Adapter
      attr_accessor :valid, :store_type, :table_id, :guest_queue_id, :track_from

      def self.get_from(session)
        self.new(session)
      end

      def initialize(attrs={})
        @valid = false
        @store_type = attrs[:store_type]
        if @store_type.present?
          case @store_type.to_sym
          when :for_merge_order
            @table_id = attrs.fetch(:table_id)
            @valid = true
            @track_from = 'FromWechat'
          when :for_pre_order
            @guest_queue_id = attrs.fetch(:guest_queue_id)
            @valid = true
            @track_from = 'FromWechat'
          when :for_wifi_order
            @valid = true
            @track_from = 'FromWifi'
          end
        end
      end

      def valid?
        @valid
      end

      def get_cart(branch, user, session)
        case store_type.to_sym
        when :for_merge_order
          table = branch.tables.find(table_id)
          line_itemables = table.order_itemables.for_merge_order.of_user(user).map(&:to_line_itemable)
          OrderService::Cart::EatInHall.new({
            line_itemables: line_itemables,
            branch: branch,
            table: table,
            user: user,
            track_from: track_from,
            ignore_essentail_product: true
          })
        when :for_pre_order
          line_itemables = user.order_itemables.for_pre_order.where(branch_id: branch.id).map(&:to_line_itemable)
          OrderService::Cart::EatInHall.new({
            line_itemables: line_itemables,
            branch: branch,
            user: user,
            track_from: track_from,
            ignore_essentail_product: true
          })
        when :for_wifi_order
          line_itemables = user.order_itemables.for_wifi_order.where(branch_id: branch.id).map(&:to_line_itemable)
          OrderService::Cart::EatInHall.new({
            line_itemables: line_itemables,
            branch: branch,
            user: user,
            track_from: track_from,
            ignore_essentail_product: true
          })
        end
      end

      def update_from_cart(cart)
        case store_type.to_sym
        when :for_merge_order
          update_merge_order_itemables(cart)
        when :for_pre_order
          update_pre_order_itemables(cart)
        when :for_wifi_order
          update_wifi_order_itemables(cart)
        end
      end

      def attach(session)
        session[:store_type] = store_type
        session[:table_id] = table_id if table_id.present?
        session[:guest_queue_id] = guest_queue_id if guest_queue_id.present?
      end

      def detach(session)
        session.delete :store_type
        session.delete :table_id
        session.delete :guest_queue_id
      end

      private
        def update_pre_order_itemables(cart)
          order_itemables = cart.user.order_itemables.for_pre_order
          comp_result = compare(cart.line_items, order_itemables)
          comp_result[:news].each_pair do |k, quantity|
            create_order_itemable(cart, k, quantity, guest_queue_id: guest_queue_id)
          end
          save_diff(comp_result[:diffs], order_itemables)
        end

        def update_merge_order_itemables(cart)
          order_itemables = cart.table.order_itemables.for_merge_order.of_user(cart.user)
          variant_ids = cart.branch.essential_products.map(&:variant_id)
          comp_result = compare(cart.line_items, order_itemables)
          comp_result[:news].each_pair do |k, quantity|
            create_order_itemable(cart, k, quantity, table_id: cart.table_id)
          end
          save_diff(comp_result[:diffs], order_itemables)
          ensure_essential_products(cart)
        end

        def update_wifi_order_itemables(cart)
          order_itemables = cart.user.order_itemables.for_wifi_order
          comp_result = compare(cart.line_items, order_itemables)
          comp_result[:news].each_pair do |k, quantity|
            create_order_itemable(cart, k, quantity, table_id: cart.table_id)
          end
          save_diff(comp_result[:diffs], order_itemables)
        end

        def save_diff(diffs, order_itemables)
          diffs.each_pair do |k, quantity|
            order_itemable = order_itemables.detect{|i| i.itemable_type == k[0] && i.itemable_id == k[1] && i.note == k[2]}
            order_itemable.quantity += quantity
            if order_itemable.quantity == 0
              order_itemable.destroy!
            else
              order_itemable.save!
            end
          end
        end

        def create_order_itemable(cart, k, quantity, append={})
          Ddt::OrderItemable.create({
            store_type: store_type,
            branch: cart.branch,
            user: cart.user,
            itemable_type: k[0],
            itemable_id: k[1],
            note: k[2],
            quantity: quantity
          }.merge(append))
        end

        def compare(line_items, order_itemables)
          gline_items = group(line_items)
          gorder_iemable = group(order_itemables)
          diffs = {}
          news = {}
          gline_items.each_pair do |k, quantity|
            q = gorder_iemable.delete(k)
            if q.present?
              diff_q = quantity - q
              diffs[k] = diff_q if diff_q != 0
            else
              news[k] = quantity
            end
          end
          gorder_iemable.each_pair do |k, quantity|
            diffs[k] = -quantity;
          end

          return {news: news, diffs: diffs}
        end

        def group(itemables)
          result = itemables.inject({}) do |h, l|
            k = [l.itemable_type, l.itemable_id, l.note]
            v = h[k]
            if v.present?
              h[k] += l.quantity
            else
              h[k] = l.quantity
            end
            h
          end
          result
        end

        def ensure_essential_products(cart)
          essential_products = cart.branch.essential_products.eat_in_hall
          if essential_products.count > 0
            count = cart.table.order_itemables.for_merge_order.where(base_user_id: nil).count
            if count == 0
              essential_products.each do |essential_product|
                quantity = essential_product.essential_quantity(cart.guest_num)
                Ddt::OrderItemable.create({
                  store_type: store_type,
                  branch: cart.branch,
                  itemable: essential_product.variant,
                  note: '',
                  quantity: quantity,
                  table_id: cart.table_id
                })
              end
            end
          end
        end

    end
  end
end
