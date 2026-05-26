# Transitional concern that bridges will_paginate → Pagy.
#
# Provides a `paginate` class method on ActiveRecord models so that
# existing code calling `Model.paginate(page: params[:page])`
# continues to work through Pagy.
#
module Ddt::Pagination
  extend ActiveSupport::Concern

  class_methods do
    def paginate(page: 1, per_page: nil)
      per_page ||= Pagy::DEFAULT[:items]
      pagy_offset = (page.to_i - 1) * per_page
      limit(per_page).offset(pagy_offset)
    end

    def per_page
      Pagy::DEFAULT[:items]
    end
  end
end
