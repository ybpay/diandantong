module Ddt
  module OrderService
    module Concern
      module OrderRelation
        extend ActiveSupport::Concern
        included do
        end

        module ClassMethods
          def belongs_to_order(options={})
            name = options.fetch(:name, "order")
            vname = "@#{name}"
            _id = options.fetch(:foreign_key, "#{name}_id").to_sym
            define_method "#{name}" do
              _class = Ddt::OrderService::Order::Base
              if instance_variable_get(vname).present?
                instance_variable_get(vname)
              else
                instance_variable_set(vname, _class.find(self.send(_id))) if self.send(_id).present?
              end
            end

            define_method "#{name}=" do |value|
              self.send("#{_id}=", value.try(:id))
              instance_variable_set(vname, value)
            end

            define_singleton_method "include_#{name}" do |*include_options|
              ids = self.all.map(&_id).compact
              loaded_orders = OrderService::Orders.includes(*include_options).find(ids)
              self.all.map do |m|
                m.send("#{name}=", loaded_orders.detect{|order| order.id == m.send(_id)})
                m
              end
            end
          end

          def has_many_orders(name, scope=nil, options={})
            if scope.is_a?(Hash)
              options = scope
              scope   = nil
            end
            _id = options.fetch(:foreign_key, "#{self.name.demodulize.underscore}_id")
            define_method "#{name}" do
              relation = OrderService::Order::Base.where(_id => self.id)
              scope ? relation.instance_exec(&scope) : relation
            end
          end

          def has_one_pay_item(options={})
            define_method :pay_item do
              vname = "@pay_item"
              if instance_variable_get(vname).present?
                instance_variable_get(vname)
              else
                foreign_key = options[:foreign_key] || "#{self.class.name.demodulize.underscore}_id"
                pay_item = self.order.pay_items.detect{|pay_item| pay_item.send(foreign_key) == self.id }
                instance_variable_set(vname, pay_item)
              end
            end
          end

          def belongs_to_order_change_log(options={})
            name = options.fetch(:name, "order_change_log")
            vname = "@#{name}"
            _id = options.fetch(:foreign_key, "#{name}_id")
            define_method "#{name}" do
              if instance_variable_get(vname).present?
                instance_variable_get(vname)
              else
                instance_variable_set(vname, self.order.order_change_logs.find(self.send(_id)))
              end
            end

            define_method "#{name}=" do |value|
              self.send("#{_id}=", value.try(:id))
              instance_variable_set(vname, value)
            end
          end
        end
      end
    end
  end
end
