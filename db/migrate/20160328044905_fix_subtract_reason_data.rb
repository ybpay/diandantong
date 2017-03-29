class FixSubtractReasonData < ActiveRecord::Migration
  def change
    reason_names = [
      "菜品估清",
      "估清",
      "过时出差",
      "客人点多",
      "客人要求",
      "落错单",
      "退酒",
      "问题食品",
      "无效单据",
      "小飞虫",
      "有异物",
      "转台",
      "漏叫起",
      "人数更改",
      "删除单据",
      "上菜太慢",
      "食品变质",
      "食品口味",
      "出口质量",
      "等叫起未出菜",
      "服务员点菜",
      "输入价格不对",
      "过迟出菜",
      "换酒",
      "拒绝项目",
      "退菜",
      "换菜",
      "异物进入",
      "资料错误",
      "换台",
      "测试"]

    @shop_ids = Ddt::Shop.pluck(:id)
    subtract_reasons = []
    @shop_ids.each do |shop_id|
      reason_names.each do |name|
        subtract_reasons << Ddt::SubtractReason.new(shop_id: shop_id, name: name, created_at: Time.now, updated_at: Time.now)
        if subtract_reasons.size == 2000
          save_to_db(subtract_reasons)
          subtract_reasons = []
        end
      end
    end
    if subtract_reasons.size > 0
      save_to_db(subtract_reasons)
    end
  end


  def save_to_db(subtract_reasons)
    Ddt::SubtractReason.import(subtract_reasons)
  end

end
