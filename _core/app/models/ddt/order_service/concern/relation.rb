module Ddt
  module OrderService
    module Concern
      module Relation
        extend ActiveSupport::Concern
        included do
          mattr_accessor :relations, instance_accessor: false do
            []
          end
          [:belongs_to, :has_many, :has_one, :has_and_belongs_to_many].each do |type|
            define_singleton_method "#{type}_relations".to_sym do
              relations.select{|relation| relation[:type] == type}
            end
          end
        end

        module ClassMethods
          def belongs_to(name, scope=nil, options={})
            if scope.is_a?(Hash)
              options = scope
              scope   = nil
            end
            # set relation
            relation = {
              name: name,
              type: :belongs_to,
              scope: scope,
              polymorphic: options[:polymorphic],
              with_deleted: options[:with_deleted],
              id_column: options.fetch(:foreign_key, "#{name}_id"),
            }
            if options[:polymorphic]
              relation[:type_column] = options.fetch(:foreign_type, "#{name}_type")
            else
              relation[:class_name] = options.fetch(:class_name, "Ddt::#{name.to_s.classify}")
            end
            self.relations << relation

            vname = "@#{name}"
            attr_accessor_with_dirty relation[:id_column]
            attr_accessor_with_dirty relation[:type_column] if options[:polymorphic]
            define_method "#{name}" do
              if options[:polymorphic]
                _class = self.send(relation[:type_column]).try(:constantize)
              else
                _class = relation[:class_name].try(:constantize)
              end
              if _class.present?
                _class = _class.with_deleted if options[:with_deleted]
                if instance_variable_defined?(vname)
                  instance_variable_get(vname)
                else
                  _id = self.send(relation[:id_column])
                  instance_variable_set(vname, _class.find_by(id: _id)) if _id.present?
                end
              end
            end
            define_method "#{name}=" do |value|
              self.send("#{relation[:id_column]}=", value.try(:id))
              self.send("#{relation[:type_column]}=", value.try(:class).try(:base_class).try(:name)) if options[:polymorphic]
              instance_variable_set(vname, value)
            end
          end

          def has_one(name, scope=nil, options={})
            if scope.is_a?(Hash)
              options = scope
              scope   = nil
            end
            # set relation
            relation = {
              name: name,
              type: :has_one,
              scope: scope,
              as: options[:as],
              with_deleted: options[:with_deleted],
              class_name: options.fetch(:class_name, "Ddt::#{name.to_s.classify}"),
              foreign_key: options[:foreign_key] || self.foreign_key || "#{self.name.demodulize.underscore}_id",
            }
            self.relations << relation

            vname = "@#{name}"
            _class = relation[:class_name].constantize
            _class = _class.with_deleted if options[:with_deleted]
            relation_proc = ->(instance){
              if options[:as].present?
                _foreign_type_key = "#{options[:as]}_type"
                _foreign_id_key = "#{options[:as]}_id"
                _relation = _class.where({_foreign_type_key => instance.class.base_class.model_name.name, _foreign_id_key => instance.id})
              else
                _class_name = options[:class_name] || "Ddt::#{name.to_s.classify}"
                _relation = _class.where({relation[:foreign_key].to_s => instance.id})
              end
              scope ? _relation.instance_exec(&scope) : _relation
            }

            define_method "#{name}" do
              if instance_variable_defined?(vname)
                instance_variable_get(vname)
              else
                instance_variable_set(vname, relation_proc.call(self).first)
              end
            end

            define_method "#{name}=" do |value|
              instance_variable_set(vname, value)
            end

            define_method "create_#{name}" do |*args|
              record = relation_proc.call(self).create(*args)
              instance_variable_set(vname, record)
              record
            end
          end

          def has_many(names, scope=nil, options={})
            if scope.is_a?(Hash)
              options = scope
              scope   = nil
            end
            # set relation
            relation = {
              name: names,
              type: :has_many,
              scope: scope,
              as: options[:as],
              class_name: options.fetch(:class_name, "Ddt::#{names.to_s.classify}"),
              foreign_key: options[:foreign_key] || self.foreign_key || "#{self.name.demodulize.underscore}_id",
            }
            self.relations << relation


            vname = "@#{names}"
            define_method "#{names}" do
              if instance_variable_defined?(vname)
                instance_variable_get(vname)
              else
                _class = relation[:class_name].constantize
                if options[:as].present?
                  _foreign_type_key = "#{options[:as]}_type"
                  _foreign_id_key = "#{options[:as]}_id"
                  _relation = _class.where({_foreign_type_key => self.class.base_class.model_name.name, _foreign_id_key => id})
                else
                  _relation = _class.where({relation[:foreign_key].to_s => self.id})
                end
                _relation = scope ? _relation.instance_exec(&scope) : _relation
                instance_variable_set(vname, _relation)
              end
            end

            define_method "#{names}=" do |value|
              instance_variable_set(vname, value)
            end
          end

          # example
          # has_and_belongs_to_many :promotions, join_table: 'ddt_promotions_orders'
          # order.promotions
          # order.promotion_ids
          # order.promotion_ids = []
          # order.clear_promotions
          # order.add_promotion(promotion)
          def has_and_belongs_to_many(names, scope, options={})
            if scope.is_a?(Hash)
              options = scope
              scope   = nil
            end
            # set relation
            relation = {
              name: names,
              type: :has_and_belongs_to_many,
              scope: scope,
              class_name: options.fetch(:class_name, "Ddt::#{names.to_s.classify}"),
              foreign_key: options[:foreign_key] || self.foreign_key || "#{self.name.demodulize.underscore}_id",
              association_foreign_key: options[:association_foreign_key] || "#{names.to_s.singularize}_id",
              join_table: options[:join_table],
            }
            self.relations << relation

            name_ids = "#{names.to_s.singularize}_ids"
            vname = "@#{name_ids}"
            _class = relation[:class_name].constantize

            define_method names do
              ids = self.send(name_ids)
              _relation = _class.where(id: ids)
              scope ? _relation.instance_exec(&scope) : _relation
            end

            define_method name_ids do
              if instance_variable_defined?(vname)
                instance_variable_get(vname)
              else
                sql = "select #{relation[:association_foreign_key]} from #{relation[:join_table]} where #{relation[:foreign_key]} = #{self.id};"
                ids = ActiveRecord::Base.connection.execute(sql).map{|row| row[0]}
                instance_variable_set(vname, ids)
              end
            end

            define_method "#{name_ids}=" do |ids|
              sql = "delete from #{relation[:join_table]} where #{relation[:foreign_key]} = #{self.id};"
              ActiveRecord::Base.connection.execute(sql)
              if ids.present?
                values = ids.map{|id| "(#{id}, #{self.id})"}.join(",")
                sql = "insert into #{relation[:join_table]}(#{relation[:association_foreign_key]}, order_id) values #{values};"
                ActiveRecord::Base.connection.execute(sql)
              end
              instance_variable_set(vname, ids)
            end

            define_method "clear_#{names}" do
              sql = "delete from #{relation[:join_table]} where #{relation[:foreign_key]} = #{self.id};"
              ActiveRecord::Base.connection.execute(sql)
              instance_variable_set(vname, [])
            end

            define_method "add_#{names.to_s.singularize}" do |value|
              if value.present? && value.is_a?(_class)
                ids = self.send(name_ids)
                unless ids.include?(value.id)
                  ids << value.id
                  self.send("#{name_ids}=", ids)
                end
              end
            end

            define_method "remove_#{names.to_s.singularize}" do |value|
              if value.present? && value.is_a?(_class)
                ids = self.send(name_ids)
                if ids.include?(value.id)
                  ids.delete(value.id)
                  self.send("#{name_ids}=", ids)
                end
              end
            end
          end
        end
      end
    end
  end
end
