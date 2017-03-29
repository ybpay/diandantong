#encoding: utf-8
class AddActiveToBranchStatus < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_cs_branch_bindings, :online
      add_column :ddt_cs_branch_bindings, :online, :boolean, default: true
      # 默认情况下强制在线,到店安装 CS 时把这个属性设置为假,这个表在 cs 架构里修改
      add_column :ddt_cs_branch_bindings, :force_online, :boolean, default: true
    end
  end
end
