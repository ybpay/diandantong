# encoding:utf-8
module Ddt
  class PreSaleStaff < Ddt::Base
    has_many :shops, class_name: "Ddt::Shop", dependent: :nullify
    ids_string_for :shops
    validates_presence_of :name, :phone, :qq, :email
    def info
      [name, qq].join(" ")
    end
  end
end
