#encoding: utf-8
class FixCdc0315Data < ActiveRecord::Migration
  def change
    # 修复 2006-03-15 小都成的数据错误
    # 美团折扣被设置成实收了
    # 总计 131.3 元
    pay_items = Ddt::PayItem.where(pay_method_name: '美团折扣').where(branch_id: 21339).where( 'created_at between "2016-03-15 00:00:00" and "2016-03-15 23:59:59"').where('pay_method_percent_of_actual > 0')
    pay_items.each { |pay_item|
      pay_item.update_column(:pay_method_percent_of_actual, 0)
    }

  end
end
