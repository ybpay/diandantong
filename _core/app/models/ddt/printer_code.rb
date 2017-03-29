#encoding: utf-8
module Ddt
  class PrinterCode < Ddt::Base
  	belongs_to :shop, class_name: "Ddt::Shop"

  	
    def self.printers_of_codes(shop, codes)
      shop.printers.where(number: codes)
    end

    def self.branch_name_of_codes(shop, branch_ids)
      shop.branches.find(branch_ids.uniq).map(&:name).to_sentence
    end
  end
end