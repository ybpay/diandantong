# encoding: utf-8
module Ddt
  class Invoice < Ddt::Base

    belongs_to_order
    acts_as_type :payer, [:personal, :company], ["个人", "公司"]
    validates_presence_of :title, :if => :is_company?

    before_create :set_invoice_type
    before_create :set_title, if: :is_personal?

    private

    def set_invoice_type
      self.invoice_type = "普通发票"
    end

    def set_title
      self.title = "个人"
    end

  end
end