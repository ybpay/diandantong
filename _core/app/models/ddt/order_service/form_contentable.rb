module Ddt
  module OrderService
    class FormContentable
      attr_accessor :form_element_id, :form_element, :type, :label, :content
      def initialize(params={})
        @form_element_id = params.fetch(:form_element_id)
        @type = params.fetch(:type, nil)
        @content = params.fetch(:content, nil)
        @form_element = FormElement.find_by(id: @form_element_id)
        if @form_element.present?
          @label = @form_element.statement
          if @content.present? && @type == "Ddt::FormElementSelect"
            @content = FormElementOption.find(@content).statement
          end
        end
      end

      def valid?
        form_element.present? && label.present? && content.present?
      end

      def self.init_list(form_contentable_attribute_array=[])
        form_contentable_attribute_array ||= []
        attr_array = form_contentable_attribute_array.map(&:symbolize_keys)
        attr_array.map{ |p| self.new(p) }.select(&:valid?)
      end

      def to_options
        {
          form_element_id: form_element_id,
          label: label,
          content: content,
        }
      end
    end
  end
end
