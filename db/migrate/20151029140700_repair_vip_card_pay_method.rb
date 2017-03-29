class RepairVipCardPayMethod < ActiveRecord::Migration
  def change
    Ddt::PayMethod.unscoped.where("deleted_at is not null").where("builtin = true").each { |pay_method|
      # 如果同一店铺里，没有同类方法，则恢复之
      pay_method.restore unless pay_method.shop.pay_methods.where(name_sym: pay_method.name_sym).present?
    }
  end
end
