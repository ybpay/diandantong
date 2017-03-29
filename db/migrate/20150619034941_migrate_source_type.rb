#encoding: utf-8
class MigrateSourceType < ActiveRecord::Migration
  def change
    Ddt::Adjustment.where(source_type: "Ddt::AbstractSource", label: "权限打折").update_all(source_type: "Ddt::PrivilegeDiscount")
    Ddt::AbstractSource.joins("LEFT JOIN ddt_adjustments ON ddt_abstract_sources.id = ddt_adjustments.source_id")
                              .where("ddt_adjustments.source_type = 'Ddt::PrivilegeDiscount'").update_all(type: "Ddt::PrivilegeDiscount")

    Ddt::Adjustment.where(source_type: "Ddt::AbstractSource", label: "免单").update_all(source_type: "Ddt::PrivilegeFreeorder", label: "权限免单")
    Ddt::AbstractSource.joins("LEFT JOIN ddt_adjustments ON ddt_abstract_sources.id = ddt_adjustments.source_id")
                              .where("ddt_adjustments.source_type = 'Ddt::PrivilegeFreeorder'").update_all(type: "Ddt::PrivilegeFreeorder")
  end
end
