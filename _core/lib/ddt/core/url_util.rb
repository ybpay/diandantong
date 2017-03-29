require 'uri'
module Ddt
  module UrlUtil

    def self.get_query(url, item_name)
      query_str = URI(url).query
      return nil if query_str.nil?
      query_str = query_str.gsub(/^\&|\&$/, '')
      return nil if query_str.blank?
      Hash[query_str.split('&').map{|query_item| query_item.split('=')}][item_name]
    end

  end
end
