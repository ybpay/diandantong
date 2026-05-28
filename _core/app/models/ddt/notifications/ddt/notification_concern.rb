module Ddt
  module NotificationConcern
    extend ActiveSupport::Concern
    included do
      extend ActiveModel::Callbacks
      include OrderService::Concern::OrderRelation
      mattr_accessor :relations, instance_accessor: false do
        []
      end
      mattr_accessor :attributes, instance_accessor: false do
        []
      end
      [:belongs_to].each do |type|
        define_singleton_method "#{type}_relations".to_sym do
          relations.select{|relation| relation[:type] == type}
        end
      end

      def attributes
        Hash[self.class.attributes.select{|key| self.respond_to?(key) }.map{|key| [key, self.send(key)] }]
      end

      attribute :type

      def type
        self.class.name
      end

      def initialize(params={})
        params.each do |k, v|
          self.send("#{k}=", v) if self.respond_to?("#{k}=")
        end
        run_callbacks :initialize do
        end
      end

      def self.init(params={})
        params = params.with_indifferent_access
        if params[:type].present?
          type = params[:type].constantize
          type.new(params)
        else
          self.new(params)
        end
      end

      define_model_callbacks :initialize, only: :after
      def self.set_from(source, options={})
        options[:targets] ||= [:shop_id, :branch_id]
        self.class_eval do
          after_initialize "set_from_#{source}".to_sym
          define_method "set_from_#{source}".to_sym do
            from_source = self.send(source)
            options[:targets].each do |target|
              if self.respond_to?(target) && self.send(target).blank? && from_source.present? && from_source.respond_to?(target)
                self.send("#{target}=", from_source.send(target))
              end
            end
          end
        end
      end
    end

    module ClassMethods

      def attribute(*keys)
        keys.map(&:to_sym).each do |key|
          attr_accessor key
          self.attributes << key
        end
      end

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
          with_discarded: options[:with_discarded],
          id_column: options.fetch(:foreign_key, "#{name}_id"),
        }
        if options[:polymorphic]
          relation[:type_column] = options.fetch(:foreign_type, "#{name}_type")
        else
          relation[:class_name] = options.fetch(:class_name, "Ddt::#{name.to_s.classify}")
        end
        self.relations << relation

        vname = "@#{name}"
        attribute relation[:id_column]
        attribute relation[:type_column] if options[:polymorphic]
        define_method "#{name}" do
          if options[:polymorphic]
            _class = self.send(relation[:type_column]).try(:constantize)
          else
            _class = relation[:class_name].try(:constantize)
          end
          if _class.present?
            _class = _class.with_discarded if options[:with_discarded]
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
    end
  end
end