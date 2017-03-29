module Ddt
  class Printer
    class Normal < Ddt::Printer
      include Ddt::Printer::ManagedPrinter
      validates_presence_of :print_spec
      # 支持标签
      # <M>  中号字体(高度为普通字体的2倍 宽度不变)
      # <D>  中号字体(宽度为普通字体的2倍 高度不变)
      # <C>  普通字体居中
      # <B>  大号字体(高度和宽度都为普通字体的2倍)
      # <CM> 中号字体居中
      # <CB> 大号字体居中
      # <QRI> 二维码图片地址
      # <PCN> 公众号
    end
  end
end
