class FixShopRechargeRecord < ActiveRecord::Migration
  def change
    Ddt::ShopRechargeRecord.joins(:lisence)
                                  .where("ddt_shop_recharge_records.note like '代理商%'")
                                  .update_all("ddt_shop_recharge_records.agent_id = ddt_lisences.agent_id")

    Ddt::ShopRechargeRecord.joins(:shop)
                                  .joins("left join ddt_agents on ddt_shops.agent_no = ddt_agents.agent_no")
                                  .where("ddt_shop_recharge_records.agent_id is null and ddt_shop_recharge_records.note like '代理商%'")
                                  .update_all("ddt_shop_recharge_records.agent_id = ddt_agents.id")
  end
end
