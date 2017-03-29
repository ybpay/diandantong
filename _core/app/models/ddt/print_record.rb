module Ddt
  class PrintRecord < Ddt::DdtEx
    include Ddt::BelongsToBranch

    belongs_to :printer, class_name: 'Ddt::Printer'

    validates_presence_of :content

    set_from :printer
  end
end