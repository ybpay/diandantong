module Ddt
  module UrlFilter
    extend ActiveSupport::Concern

    URL_BAN_KEYS = %w[user_open_id open_id code]
    URL_FILTER_REGEXP = Regexp.new(URL_BAN_KEYS.map{|key| "#{key}="}.join("|"))

    module ClassMethods
      def filter_urls_for(*column_names)
        before_save :filter_urls

        define_method :filter_urls do
          column_names.each do |column_name|
            url = self.send(column_name)
            self.send "#{column_name}=", filter_url(url)
          end
        end
      end
    end


    def filter_url(url_str)
      return url_str if url_str.blank?
      return url_str unless url_str =~ URL_FILTER_REGEXP
      uri = URI(url_str)
      query_hash = Hash[uri.query.split('&').map{|i| i.split('=')}]
      URL_BAN_KEYS.each{|key| query_hash.delete(key)}
      uri.query = query_hash.to_query
      uri.to_s
    end

  end
end
