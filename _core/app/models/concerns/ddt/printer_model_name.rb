module Ddt
  module PrinterModelName
    extend ActiveSupport::Concern
    included do
    end

    module ClassMethods
      def model_name
        Ddt::Printer.model_name
      end
    end
  end
end