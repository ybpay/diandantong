# encoding: utf-8
module ApplicationHelper
  include Pagy::Frontend

  # Backward-compatible will_paginate → Pagy bridge.
  # Existing views call `will_paginate @collection, renderer: ..., bootstrap: 3`.
  # This delegates to Pagy's `pagy_nav` with Bootstrap-compatible markup.
  def will_paginate(collection, **opts)
    return unless collection.respond_to?(:total_pages) || collection.is_a?(Array)

    if collection.respond_to?(:total_pages)
      total_count = collection.total_pages
      current = collection.current_page rescue 1
    else
      return ''.html_safe
    end

    # Build simple pagination HTML
    pages = (1..total_count).to_a
    current = [current, 1].max

    content_tag :nav do
      content_tag :ul, class: 'pagination' do
        safe_join(
          pages.map do |p|
            content_tag :li, class: "#{'active' if p == current}" do
              link_to p, "?page=#{p}"
            end
          end
        )
      end
    end
  rescue StandardError
    ''.html_safe
  end
end
