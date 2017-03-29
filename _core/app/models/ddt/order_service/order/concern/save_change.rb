module Ddt
  module OrderService
    module Order
      module Concern
        module SaveChange
          extend ActiveSupport::Concern
          included do
          end

          module ClassMethods
            def batch_update(*orders)
              changed_values = orders.map do |order|
                order.all_changed_values.merge(pre_updated_at: order.updated_at, id: order.id)
              end
              OrderService::Api::Order.batch_update({ orders: changed_values })
            end
          end

          def save(options={})
            if self.any_changed? || options[:touch]
              options = {
                select: [:id, :updated_at],
                includes: collection_attr_names
              }
              collection_attr_names.each do |attr_name|
                options["#{attr_name.to_s.singularize}_select".to_sym] = [:id, :created_at, :updated_at]
              end
              all_changes = all_changed_values
              total_changed if all_changes[:total]
              changes = OrderService::Api::Order.update(self.id, all_changes.merge(pre_updated_at: self.updated_at), options)
              apply_changes(changes)
              self
            end
          end

          def any_changed?
            self.changed? || self.collection_attrs.compact.any?(&:changed?)
          end

          def all_changed_values
            values = self.changed_values
            collection_attr_names.each do |attr_name|
              values[attr_name] = self.send(attr_name).changed_values if self.send(attr_name)
            end
            values
          end

          private
          def apply_changes(changes={})
            self.updated_at = changes[:updated_at]
            changes_applied
            self.collection_attr_names.each do |attr_name|
              self.send(attr_name).apply_changes(changes[attr_name]) if self.send(attr_name)
            end
          end
        end
      end
    end
  end
end
