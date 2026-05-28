module Ddt
  module OrderService
    class Orders
      attr_accessor :current_page, :per_page, :is_first_page, :is_last_page, :total_count, :total_pages, :sort, :count, :content
      attr_accessor :orders
      include Enumerable
      delegate :each, :first, :last, :[], :size, to: :orders

      def initialize(hash = {})
        hash.each do |key, value|
          self.send(:"#{key}=", value)
        end
        shop_ids = @content.map{|h| h[:shop_id]}.compact.uniq
        shops = Shop.where(id: shop_ids)
        @orders = @content.map do |order_hash|
          shop = shops.detect{|shop| shop.id = order_hash[:shop_id]}
          OrderService::Order::Base.init(order_hash.reverse_merge(shop: shop))
        end
      end

      def relation_includes(*args)
        # belongs_to [:shop, :branch, :user, :vip_info, :waiter, :settle_account]
        # has_one [:bind_qr_code_scene, :comment, :coupon, :voucher, :invoice, :card_deduction, :credits_deduction, :verify_vip_info_qr_code_scene]
        # has_many [:order_calls, :payments]
        args.each do |arg|
          relation = OrderService::Order::Base.relations.detect{|r| r[:name] == arg }
          if relation.present?
            case relation[:type]
            when :belongs_to
              ids = orders.map{|order| order.send(relation[:id_column])}.compact.uniq
              _class = relation[:class_name].constantize
              _class = _class.with_discarded if relation[:with_discarded]
              relation_models = _class.where(id: ids)
              relation_models = relation[:scope] ? relation_models.instance_exec(&relation[:scope]) : relation_models
              orders.each do |order|
                relation_model = relation_models.detect{|m| m.id == order.send(relation[:id_column])}
                order.send("#{relation[:name]}=", relation_model)
              end
            when :has_one
              _class = relation[:class_name].constantize
              _class = _class.with_discarded if relation[:with_discarded]
              relation_models = _class.where(relation[:foreign_key] => orders.map(&:id))
              relation_models = relation[:scope] ? relation_models.instance_exec(&relation[:scope]) : relation_models
              orders.each do |order|
                relation_model = relation_models.detect{|m| m.send(relation[:foreign_key]) == order.id }
                order.send("#{relation[:name]}=", relation_model)
              end
            when :has_many
              _class = relation[:class_name].constantize
              relation_models = _class.where(relation[:foreign_key] => orders.map(&:id))
              relation_models = relation[:scope] ? relation_models.instance_exec(&relation[:scope]) : relation_models
              orders.each do |order|
                models = relation_models.to_a.select{|m| m.send(relation[:foreign_key]) == order.id }
                order.send("#{relation[:name]}=", models)
              end
            end
          end
        end
        self
      end

      def all
        orders
      end

      def to_ary
        orders
      end

      class Query
        attr_accessor :query_params, :options
        include Enumerable
        def initialize
          @query_params = {
            page: 1,
            per_page: 1000
          }
          @options = {
            includes: [:line_items, :adjustments, :pay_items, :order_change_logs, :form_contents, :line_item_trace_points]
          }
          # options {
          #   select: [..],
          #   includes: [:line_items, :adjustments, :pay_items, :order_change_logs, :line_item_trace_points, :form_contents]
          #   line_item_select: [..]
          #   adjustment_select: [..]
          #   pay_item_select: [..]
          #   order_change_log_select: [..]
          #   line_item_trace_point_select: [..]
          #   form_content_select: [..]
          # }
        end

        def self.scope(name, block)
          define_method name do |*args|
            result = self.instance_exec *args, &block
            result ? result : self
          end
        end

        # scopes
        scope :by_state    , ->(state){ where(state: state) if state.present? }
        scope :by_type     , ->(type){ where(type: type) if type.present? }
        scope :by_pay_method, ->(pay_method){  where(pay_method: pay_method) if pay_method.present? }
        scope :by_user     , ->(user){ where(base_user_id: user.id) if user.present? }
        scope :by_number   , ->(number){ where(number_cont: number) if number.present?}
        scope :by_placed_at, ->(start_at, end_at){ where(placed_at_gt: start_at, placed_at_lt: end_at) if start_at.present? && end_at.present? }

        scope :imcompleted , ->{ where(completed_at_null: 1) }
        scope :completed   , ->{ where(completed_at_not_null: 1) }
        scope :not_canceled, ->{ where(state_not_eq: :canceled)}
        scope :active      , ->{ where(state: [:pending, :confirmed]).order(placed_at: :desc)}
        scope :today, ->{ where(placed_at_gt: DateTime.now.beginning_of_day, placed_at_lt: DateTime.now.end_of_day)}
        scope :recent, ->(last){where(placed_at_gt: last)}
        scope :paid, ->{where(pay_item_state: :paid)}
        scope :paid_or_partial_paid, ->{where(pay_item_state: [:paid, :partial_paid])}
        scope :pending, ->{ where(state: :pending)}
        scope :confirmed, ->{ where(state: :confirmed)}
        scope :completed, ->{ where(state: :completed)}
        scope :canceled, ->{ where(state: :canceled)}

        scope :eat_in_hall, ->{ where(type: 'Ddt::EatInHallOrder')}
        scope :delivery, ->{ where(type: 'Ddt::DeliveryOrder')}
        scope :fastfood, ->{ where(type: 'Ddt::FastfoodOrder')}
        scope :reservation, ->{ where(type: 'Ddt::ReservationOrder')}
        scope :payment, ->{ where(type: 'Ddt::PaymentOrder')}
        scope :groupon, ->{ where(type: 'Ddt::GrouponOrder')}
        scope :recharge, ->{ where(type: 'Ddt::RechargeOrder')}

        scope :by_name, ->(name){ where(delivery_name_or_reservation_name_const: name) if name.present? }
        scope :by_phone, ->(phone){ where(delivery_phone_or_reservation_phone_const: phone) if phone.present? }

        scope :accessible_by, ->(account){
          if account.is_admin? || account.is_boss?
            self
          else
            where(branch_id: account.managed_branches.map(&:id) )
          end
        }

        scope :order, ->(condition){ where(s: condition)}
        scope :paginate, ->(condition){ where(page: condition[:page] || 1, per_page: condition[:per_page] || 20)}

        def where(condition={})
          params = {}
          if condition.present?
            condition = condition.symbolize_keys
            condition.each do |key, value|
              if self.class.ransack_keys.any?{|k| key.to_s.end_with?(k) } || [:page, :per_page, :s].include?(key)
                if key == :s
                  if String === value
                    params[key] = value
                  elsif Hash === value
                    params[key] = value.map{|k, v| [k, v].join(" ")}.join(",")
                  end
                else
                  params[key] = value
                end
              else
                if value.is_a? Array
                  params["#{key}_in".to_sym] = value
                elsif value.is_a? Range
                  params["#{key}_gteq".to_sym] = value.begin
                  params["#{key}_lteq".to_sym] = value.end
                else
                  params["#{key}_eq".to_sym] = value
                end
              end
            end
            self.query_params = self.query_params.merge(params) if params.present?
          end
          self
        end

        def self.ransack_keys
          %W[_cont _not_cont _cont_any _start _end _gt _gteq _lt _lteq _in _present _blank _null _not_null _eq _not_eq]
        end

        def select(columns, relation_columns={})
          self.options[:select] = columns
          self.options[:line_item_select] = relation_columns[:line_item]
          self.options[:adjustment_select] = relation_columns[:adjustment]
          self.options[:pay_item_select] = relation_columns[:pay_item]
          self.options[:order_change_log_select] = relation_columns[:order_change_log]
          self.options[:line_item_trace_point_select] = relation_columns[:line_item_trace_point]
          self.options[:form_content_select] = relation_columns[:form_content_select]
          self
        end

        def includes(*relations)
          self.options[:includes] = relations
          self
        end

        def includes_none
          includes(*[])
        end

        def includes_all
          includes(:line_items, :adjustments, :pay_items, :order_change_logs, :line_item_trace_points, :form_contents)
        end

        def query
          result = OrderService::Api::Order.query(query_params.select{|_, v| v}, options)
          orders = OrderService::Orders.new(result)
        end

        def find(id)
          if id.is_a? Array
            id.present? ? where(id_in: id).query : []
          else
            if id.present?
              result = OrderService::Api::Order.get(id, options)
              order = OrderService::Order::Base.init(result)
            end
          end
        end

        def find_by(params={})
          where(params).paginate(page: 1, per_page: 1).query.first
        end

        def first
          order(id: :asc).paginate(page: 1, per_page: 1).query.first
        end

        def last
          order(id: :desc).paginate(page: 1, per_page: 1).query.first
        end

        def limit(limit_count)
          paginate(page: 1, per_page: limit_count)
        end

        def count
          OrderService::Api::Order.count(query_params.except(:s, :page, :per_page))
        end
        alias_method :size, :count

        concerning :MockForRansack do
          def result(params={})
            self
          end

          def form_model
            Query::Q.new(query_params)
          end

          def ransack_model
            Zone.ransack(query_params)
          end
        end

        delegate :each, to: :query

        def self.query_methods
          [
            :where, :select, :includes, :includes_none, :query, :find, :find_by, :first, :last, :count, :limit,
            :by_state, :by_type, :by_pay_method, :by_user, :by_number, :by_placed_at,
            :imcompleted, :completed, :not_canceled, :active, :today, :recent, :paid, :paid_or_partial_paid,
            :pending, :completed, :canceled,
            :eat_in_hall, :delivery, :fastfood, :reservation, :payment, :groupon, :recharge,
            :accessible_by, :order, :paginate,
            :by_name, :by_phone,
          ]
        end

        class Q
          attr_accessor :query_params
          def initialize(query_params={})
            @query_params = query_params
          end

          def method_missing(method_name, *args)
            query_params.fetch(method_name.to_sym, nil)
          end

          def self.model_name
            @_model_name ||= ActiveModel::Name.new(self, Ddt::OrderService::Orders::Query)
          end
        end
      end

      OrderService::Orders::Query.query_methods.each do |name|
        define_singleton_method name do |*args|
          OrderService::Orders::Query.new.send(*args.unshift(name))
        end
      end

      class << self
        delegate :query_methods, to: OrderService::Orders::Query
      end
    end
  end
end
