module Ddt
  module BillTemplate
    module Tag
      class ItemName < Tag::Base
        tag_attr :width, :int, default: 20
        tag_attr :align, :string, default: "left"
        attr_accessor :splited_names

        def render(name, note=nil)
          name_with_note = note.present? ? "#{name}[#{note}]" : name
          text = get_splited_names(name_with_note)[0]
          format_string_with_escape(width, text)
        end

        def render_overflow(name, note=nil)
          name_with_note = note.present? ? "#{name}[#{note}]" : name
          splited_names = get_splited_names(name_with_note)
          first_name = splited_names[0]
          first_name =~ /^(\s)*/
          prefix_space = $1
          overflow_names = splited_names[1..-1]
          overflow_names.map do |overflow_name|
            "#{prefix_space} #{format_string_with_escape(width - 1, overflow_name)}"
          end
        end

        private

        def format_string_with_escape(total_size, str)
          str.fixed_width(total_size, float: align).gsub('%', '%%')
        end

        def get_splited_names(name)
          item_name_split(name, width)
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
      end
    end
  end
end