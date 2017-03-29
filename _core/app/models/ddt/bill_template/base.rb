module Ddt
  module BillTemplate
    class Base
      def setting
        @setting ||= branch.bill_template_setting
      end

      def render_with_error_catch
        begin
          render_without_error_catch
        rescue Exception => e
          if Rails.env == 'production'
            Rails.logger.error "打印模版错误，错误信息为：#{e.message}"
            "打印模版错误 #{e.message}"
          else
            raise e
          end
        end
      end

      def template_from_setting
        setting.send("#{self.class.name.split("::").last(2).join('_').underscore}_template")
      end

      def replace_p_tag(text)
        TagHelper.replace_p_tag(text)
      end

      # 打印小票的宽度，以一个英文字母(字体等宽)为单位(汉字宽度为2)
      def bill_width
        if printer.is_normal?
          printer.print_spec.to_s == '58' ? 32 : 40
        else
          32
        end
      end

      def base_inline_value_names
        [:hyphen_line, :hyphen_line, :item_title]
      end

      def hyphen_line
        "－" * (bill_width/2)
      end

      def asterisk_line
        "*" * bill_width
      end

      def item_title
        case bill_width
        when 32
          # 32 = 4*2 + 12 + 2*2 + 4 + 2*2
          "商品名称            数量    小计"
        when 40
          # 40 = 4*2 + 18 + 2*2 + 6 + 2*2
          "商品名称                  数量      小计"
        end
      end

      def replace_inline_values(text, names)
        output = text
        names.each do |name|
          output = output.gsub("{{#{name}}}", "#{self.send(name)}") if output.include?("{{#{name}}}") && self.respond_to?(name, true)
        end
        output
      end

      def replace_item_inline_values(text, item, names)
        output = text
        names.each do |name|
          output = output.gsub("{{#{name}}}", "#{item.send(name)}") if output.include?("{{#{name}}}") && item.respond_to?(name, true)
        end
        output
      end
    end
  end
end
