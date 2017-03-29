# encoding: utf-8
module Ddt
  class AgentPrinter < Ddt::Base
    belongs_to :agent, class_name: "Ddt::Agent"
    validates_presence_of :printer_code, :secret, :token # note

    def check_exist?
      response = Ddt::Printer::Api.send_get("/printers/check_normal", { printer_code: printer_code, secret: secret, token: token })
      if response[:status]
        true
      else
        self.errors[:base] << "该编号或密钥或Token错误，导致无法查询该授权吗状态"
        false
      end
    end
  end
end
