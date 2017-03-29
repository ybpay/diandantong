module Ddt
  module BillTemplate
    module TagHelper
      def self.scan_tag(template, tag_name)
        # /<([a-z-]+)([^>\/]*)(?:>(.*?)<\/\1>|\/>)/m
        tags = []
        regex = /<(#{tag_name})([^->\/]*)(?:>(.*?)<\/\1>|\/>)/m
        if tag_name == "if"
          regex = /[\n]?<(#{tag_name})([^->\/]*)(?:>(.*?)<\/\1>|\/>)/m
        elsif tag_name == "repeat"
          regex = /(?<rec><repeat([^->\/]*)(?:>((((?!repeat).)|\g<rec>)*?)<\/repeat>))/m
        end
        template.scan(regex) do |name, attrs, content|
          body = $&
          if tag_name == "repeat"
            body =~ /<repeat([^->\/]*)(?:>(.*))<\/repeat>/m
            attrs = $1
            content = $2
            attrs_hash = tag_attr_to_hash(attrs.strip)
          else
            attrs_hash = tag_attr_to_hash(attrs.strip)
          end
          tags << BillTemplate::Tag.const_get(tag_name.underscore.classify).new(body: body, attrs: attrs_hash, content: content || "")
        end
        tags
      end

      def self.replace_p_tag(text)
        replaced_text = text
        p_tags = scan_tag(text, "p")
        p_tags.each do |tag|
          replaced_text = replaced_text.sub(tag.body, tag.render)
        end
        replaced_text
      end

      private
      def self.tag_attr_to_hash(tag_attr)
        tag_attr.strip.split(/\s+/).select{|a| a.include?('=')}.map{|a| a.split(/\=/,2)}.to_h.to_options
      end
    end
  end
end