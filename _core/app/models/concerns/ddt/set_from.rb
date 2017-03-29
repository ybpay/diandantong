module Ddt
  module SetFrom
    extend ActiveSupport::Concern
    included do
    end

    module ClassMethods
      def set_from(source, options={})
        options[:targets] ||= [:shop_id, :branch_id]
        self.class_eval do
          before_validation "set_from_#{source}".to_sym, if: :new_record?
          after_initialize "set_from_#{source}".to_sym, if: :new_record?
          define_method "set_from_#{source}".to_sym do
            from_source = nil
            options[:targets].each do |target|
              if self.respond_to?(target) && self.send(target).blank?
                from_source ||= self.send(source)
                if from_source.present? && from_source.respond_to?(target)
                  self.send("#{target}=", from_source.send(target))
                end
              end
            end
          end
        end
      end

      def set_from_tcc(source, options={})
        options[:targets] ||= [:shop_id, :branch_id]
        cache_prefix = options[:cache_prefix] || source
        self.class_eval do
          before_validation "set_from_#{source}".to_sym, if: :new_record?
          after_initialize "set_from_#{source}".to_sym, if: :new_record?
          define_method "set_from_#{source}".to_sym do
            from_source = nil
            options[:targets].each do |target|
              if self.respond_to?(target) && self.send(target).blank?
                from_source ||= TCC.fetch("#{cache_prefix}.#{self.send("#{source}_id")}"){self.send(source)}
                if from_source.present? && from_source.respond_to?(target)
                  self.send("#{target}=", from_source.send(target))
                end
              end
            end
          end
        end
      end


      def set_shop_from(source)
        set_from(source, targets: [:shop_id])
      end

      def set_shop_and_branch_from(source)
        set_from(source, targets: [:shop_id, :branch_id])
      end
    end
  end
end