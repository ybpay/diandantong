module Ddt
  module Api
    module Pagination
      extend ActiveSupport::Concern

      private

      def paginate_collection(collection, base_url: nil)
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 20).to_i
        per_page = [per_page, 100].min

        offset = (page - 1) * per_page
        total_count = collection.count

        items = collection.offset(offset).limit(per_page)

        pagination_headers(page, per_page, total_count, base_url)
        items
      end

      def pagination_headers(page, per_page, total_count, base_url)
        total_pages = (total_count.to_f / per_page).ceil
        links = []

        url = base_url || request.base_url + request.path

        if page > 1
          links << "<#{url}?page=#{page - 1}&per_page=#{per_page}>; rel=\"prev\""
        end
        if page < total_pages
          links << "<#{url}?page=#{page + 1}&per_page=#{per_page}>; rel=\"next\""
        end
        links << "<#{url}?page=1&per_page=#{per_page}>; rel=\"first\""
        links << "<#{url}?page=#{total_pages}&per_page=#{per_page}>; rel=\"last\""

        response.headers["Link"] = links.join(", ") if links.any?
        response.headers["X-Total-Count"] = total_count.to_s
        response.headers["X-Total-Pages"] = total_pages.to_s
        response.headers["X-Per-Page"] = per_page.to_s
        response.headers["X-Page"] = page.to_s
      end

      def render_paginated(collection, serializer: nil, each_serializer: nil)
        items = paginate_collection(collection)
        json = serialize_collection(items, serializer: serializer, each_serializer: each_serializer)
        render json: { data: json }
      end

      def serialize_collection(items, serializer: nil, each_serializer: nil)
        items.map { |item| serialize_item(item, serializer: serializer || each_serializer) }
      end

      def serialize_item(item, serializer: nil)
        if serializer
          serializer.new(item).as_json
        elsif item.respond_to?(:as_api_json)
          item.as_api_json
        else
          item.as_json
        end
      end
    end
  end
end
