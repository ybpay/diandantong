module Ddt
  module BillHelper
    extend ActiveSupport::Concern
    included do

      def format_string_with_escape(total_size, str)
        str.fixed_width(total_size).gsub('%', '%%')
      end

      def item_name_split(name, width)
        array = []
        n = ""
        w = 0
        name.split('').each do |s|
          ns = (s.bytesize == 3 ? 2 : 1)
          w += ns
          if w > width
            array << n
            n = s
            w = ns
          else
            n += s
          end
        end
        array << n if n.present?
        array
      end

      def bill_width(spec="58")
        spec.to_s == "58" ? 32 : 40
      end

      def split_query_all(query)
        query[:page] = query[:page] || 1
        query[:per_page] = query[:per_page] || Rails.env.production? ? 200 : 10
        current = yield query
        while current.size == query[:per_page]
          query[:page] += 1
          yield query
        end
      end

    end
  end
end
