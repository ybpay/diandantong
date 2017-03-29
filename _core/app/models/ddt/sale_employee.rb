# encoding:utf-8
module Ddt
  class SaleEmployee < Ddt::Base
    has_many :shops, class_name: "Ddt::Shop", dependent: :nullify
    has_many :agents, class_name: "Ddt::Agent", dependent: :nullify
    ids_string_for :shops, :agents
    validates_presence_of :name, :phone, :qq, :email
    def info
      [name, qq].join(" ")
    end

    def all_shop_ids
      (self.shops.pluck(:id) + self.agents.map{|anget| agent.shops.pluck(:id) }.flatten).uniq
    end

    def all_shops
      Ddt::Shop.where(id: all_shop_ids)
    end
  end
end
