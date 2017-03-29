module Ddt
  class BaseSearch
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    class << self
      def persistence(filter, params)
        if self.valid?(params)
          filter.name = params.delete(:name)
          filter.conditions_label = to_label(params)
          filter.ransack_q = params
          filter.save
        else
          false
        end
      end

      def valid?(params)
        return true
      end

      def to_label
        raise "#{self.name}::to_label not overwrite"
      end
    end
  end
end
