module Ddt
  module OrderService
    module Collection
      class FormContents < Collection::Base
        def to_form_contentable_options
          self.map(&:to_form_contentable_options)
        end
      end
    end
  end
end