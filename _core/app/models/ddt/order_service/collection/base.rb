module Ddt
  module OrderService
    module Collection
      class Base
        attr_accessor :items
        include Enumerable
        def initialize(array=[])
          @items = array
        end
        delegate :each, :first, :last, :count, :index, to: :alive_items
        delegate :push, :delete, to: :items

        def to_a
          alive_items
        end

        def to_ary
          to_a
        end

        def alive_items
          items.reject(&:destroyed?)
        end

        def changed_values
          self.changed.map(&:changed_values)
        end

        def changed
          items.select(&:changed?)
        end

        def changed?
          items.any?(&:changed?)
        end

        def deleted
          items.select(&:destroyed?)
        end

        def with_discarded
          items
        end

        def pressent?
          count > 0
        end

        def blank?
          !pressent?
        end

        def destroy_all
          self.each(&:destroy)
        end

        def find(id)
          detect{|item| item.id == id.to_i }
        end

        def apply_changes(changes)
          self.deleted.each{|item| self.delete(item) }
          self.each_with_index do |item, index|
            item.apply_change(changes[index])
          end
        end

        def self.scope(name, block)
          define_method name do |*args|
            result = self.instance_exec *args, &block
            result ? self.class.new(result) : self
          end
        end
      end
    end
  end
end
