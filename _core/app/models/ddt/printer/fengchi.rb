module Ddt
  class Printer
    class Fengchi < Ddt::Printer
      include Ddt::Printer::ManagedPrinter
      # 普通字体 |5
      # 大号字体 <B> |7
      # 二维码 <QR> |2
      def print(contents, times=nil, uuid: nil)
        times ||= self.times
        if contents.present?
          contents = contents.is_a?(Array) ? contents : [contents]
          contents.map do |content|
            content = content.gsub(%r{<M>}, "<B>").gsub(%r{</M>}, "</B>")
            content = content.gsub(%r{<D>}, "<B>").gsub(%r{</D>}, "</B>")
            content = content.gsub(%r{<C>}, "").gsub(%r{</C>}, "")
            content = content.gsub(%r{<CM>}, "<B>").gsub(%r{</CM>}, "</B>")
            content = content.gsub(%r{<CD>}, "<B>").gsub(%r{</CD>}, "</B>")
            record_id = send_to_print(content, times)
            if record_id.present?
              self.print_records.create!(content: content, times: times, record_id: record_id)
              true
            else
              false
            end
          end
        end
      end
    end
  end
end