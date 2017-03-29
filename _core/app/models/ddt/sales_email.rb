# encoding:utf-8
module Ddt
  class SalesEmail < Ddt::Base

    before_create do
      self.ticket = 0
    end

    def self.next
      SalesEmail.order(:ticket => :asc).first
    end

  end
end
