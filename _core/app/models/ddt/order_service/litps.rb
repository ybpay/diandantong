module Ddt
  module OrderService
    class Litps
      attr_accessor :current_page, :per_page, :is_first_page, :is_last_page, :total_count, :total_pages, :sort, :count, :content
      attr_accessor :litps
      include Enumerable
      delegate :each, :first, :last, :[], to: :litps

      def initialize(hash = {})
        hash.each do |key, value|
          self.send(:"#{key}=", value)
        end
        @litps = @content.map do |litp_hash|
          OrderService::Litp.new(litp_hash)
        end
      end

      def all
        litps
      end

      class Query
        attr_accessor :query_params, :options
        include Enumerable
        def initialize
          @query_params = {
            page: 1,
            per_page: 20
          }
        end

        def self.scope(name, block)
          define_method name do |*args|
            result = self.instance_exec *args, &block
            result ? result : self
          end
        end

        # scopes
        scope :by_state, ->(state){ where(state: state) if state.present? }
        scope :by_created_at, ->(start_at, end_at){ where(created_at_gt: start_at, created_at_lt: end_at) if start_at.present? && end_at.present? }
        scope :eat_in_hall, ->{ where(order_type_eq: "Ddt::EatInHallOrder")}
        scope :today, ->{ where(created_at: Time.now.beginning_of_day..Time.now)}
        scope :in_hours, ->(t){ where(created_at: t.hours.ago..Time.now) if t.present? }
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

        def query
          result = OrderService::Api::Litp.query(query_params.select{|_, v| v})
          litps = OrderService::Litps.new(result)
        end

        def find(id)
          if id.is_a? Array
            id.present? ? where(id_in: id).query : []
          else
            if id.present?
              result = OrderService::Api::Litp.get(id)
              litp = OrderService::Litp.new(result)
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
          OrderService::Api::Litp.count(query_params.except(:s, :page, :per_page))
        end
        alias_method :size, :count

        delegate :each, to: :query

        def self.query_methods
          [
            :where, :query, :find, :find_by, :first, :last, :count, :limit,
            :eat_in_hall, :by_state, :by_created_at, :today, :in_hours,
            :order, :paginate,
          ]
        end
      end

      OrderService::Litps::Query.query_methods.each do |name|
        define_singleton_method name do |*args|
          OrderService::Litps::Query.new.send(*args.unshift(name))
        end
      end

      class << self
        delegate :query_methods, to: OrderService::Litps::Query
      end
    end
  end
end
