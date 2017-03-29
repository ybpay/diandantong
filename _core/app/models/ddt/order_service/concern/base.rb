module Ddt
  module OrderService
    module Concern
      module Base
        extend ActiveSupport::Concern
        included do
          include ShopForeign
          include ActiveModel::Validations
          include ActiveModel::Dirty
          include ActsAsType
          include OrderService::Concern::Relation
          include OrderService::Concern::OrderRelation
        end

        module ClassMethods
          def table_name
          end

          # def i18n_scope
          #   :activerecord
          # end

          # def model_name
          #   name.gsub("OrderService::", "").constantize.model_name
          # end

          def base_class
            self
          end

          def transaction(&block)
            ActiveRecord::Base.transaction(&block)
          end

          def attr_accessor_with_dirty(*keys)
            define_attribute_methods keys
            keys.each do |key|
              define_method key do
                instance_variable_get("@#{key}")
              end

              define_method "#{key}=" do |value|
                self.send("#{key}_will_change!") unless value == instance_variable_get("@#{key}")
                instance_variable_set("@#{key}", value)
                changed_attributes.delete(key) if self.send("#{key}_was") == value
                value
              end
            end
          end

          def collection_attr_accessor(*names)
            define_method :collection_attr_names do
              names
            end
            define_method :collection_attrs do
              names.map{|name| self.send(name)}
            end
            names.each do |name|
              define_method name do
                instance_variable_get("@#{name}")
              end
              define_method "#{name}=" do |array|
                instance_variable_set("@#{name}", Array === array ? OrderService::Collection.const_get(name.to_s.camelize).new(array) : array)
              end
            end
          end

          def init_to_time(*columns)
            columns.each do |column|
              define_method "#{column}=" do |value|
                if Integer === value
                  instance_variable_set("@#{column}", Time.at(value/1000))
                else
                  instance_variable_set("@#{column}", value)
                end
              end
            end
          end

          def url_method_for(*names)
            names.each do |name|
              define_method "#{name}_url" do
                URI.join(Rails.application.routes.url_helpers.ddt_url, self.send("#{name}_path")).to_s
              end
            end
          end

          def boolean_method_for(*columns)
            columns.each do |column|
              define_method "#{column}?" do
                !!self.send(column)
              end
            end
          end
        end

        def transaction(&block)
          ActiveRecord::Base.transaction(&block)
        end

        def new?
          self.id.blank?
        end
        alias_method :new_record?, :new?

        def exists?
          !new?
        end

        def touch(time_at)
          self.send("#{time_at}=", current_time)
        end

        def changed_values
          if exists?
            if self.try(:_destroy)
              { id: self.id, destroy: self._destroy }
            else
              self.changes.map{|key, values| [key.to_sym, values[1]]}.to_h.merge(id: self.id)
            end
          else
            self.changes.map{|key, values| [key.to_sym, values[1]]}.to_h
          end
        end

        def current_time
          # Time.now.change(usec: 0)
          Time.now
        end
      end
    end
  end
end