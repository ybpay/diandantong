#encoding: utf-8
module Ddt
  class TargetsCustom < Ddt::Base
    include Ddt::BelongsToBranch

    KEYS = [
      { key: 0x001, label: "换台"},
      { key: 0x002, label: "并台"},
      { key: 0x003, label: "催单"},
      { key: 0x004, label: "加急"},
      { key: 0x005, label: "退菜"},
      { key: 0x006, label: "小票补打"},
      { key: 0x007, label: "加菜"}
    ]

    def self.create_default(branch, key, default_targets)
      targets = []
      default_targets.each do |targetable|
        targets << Ddt::Target.find_or_create_by(shop_id: branch.shop_id, branch_id: branch.id, targetable: targetable)
      end
      self.create(shop_id: branch.shop_id, branch_id: branch.id, key: key, target_ids: targets.map(&:id).join(","))
    end

    def label
      (KEYS.find{|kobj| kobj[:key] == key})[:label]
    end

    def targetables
      targets.map(&:targetable)
    end

    def targets
      self.branch.targets.where(id: target_ids_array)
    end

    def target_ids_array
      return [] if target_ids.blank?
      target_ids.split(",").map(&:to_i)
    end

  end
end
    # t.integer  "key"
    # t.string   "target_ids"
    # t.integer  "shop_id"
    # t.integer  "branch_id"
    # t.datetime "created_at"
    # t.datetime "updated_at"
