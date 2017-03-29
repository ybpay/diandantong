module Ddt
  module OrderService
    class FormContent
      include OrderService::Concern::Base
      include OrderService::Concern::BelongsToOrder
      belongs_to :form_element
      attr_accessor_with_dirty :id, :label, :content, :deleted_at, :created_at, :updated_at
      def initialize(params={})
        super
        changes_applied if exists?
      end

      def to_form_contentable_options
        [:form_element_id, :label, :content].inject({}) do |options, key|
          options[key] = self.send(key)
          options
        end
      end
    end
  end
end