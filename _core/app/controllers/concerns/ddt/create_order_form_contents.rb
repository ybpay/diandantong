# encoding: utf-8
module Ddt
  # use form_contentable
  module CreateOrderFormContents
    extend ActiveSupport::Concern
    included do
      before_action :create_form_contents, only: [:create]
    end

    private
    def create_form_contents
      form_contents_record.each do |k, form_content_params|
        @cart.form_contents.create!(form_content_params)
      end
    end

    def form_contents_record
      form_contents_attributes = {}
      # params[:order][:form_contents] = [
      #   {
      #     form_element_id
      #     content
      #     type
      #   }
      # ]
      if params[:order].present? && params[:order][:form_contents].present?
        params[:order][:form_contents].each_with_index do |f, i|
          form_element = FormElement.find f[:form_element_id]
          if f[:content].present? && f[:type] == "Ddt::FormElementSelect"
            form_option = FormElementOption.find f[:content]
            form_contents_attributes.merge!({i.to_s => package_form_content(f, form_element, form_option)})
          else
            form_contents_attributes.merge!({i.to_s => package_form_content(f, form_element)})
          end
        end
        params[:order].delete(:form_contents)
      end
      form_contents_attributes
    end

    def package_form_content(data, form_element, form_option = nil)
      {
        form_element_id: form_element.id,
        label: form_element.statement,
        content: (form_option ? form_option.statement : data[:content])
      }
    end

  end
end
