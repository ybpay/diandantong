class FixVipPhone < ActiveRecord::Migration
  def change
    result = Ddt::VipInfo.where.not(phone: nil).group(:shop_id, :phone).having("count(*) > 1").count
    result.each do |k, count|
      puts "shop_id, phone, count = #{k[0]}, #{k[1]}, #{count}"
      Ddt::VipInfo.where(shop_id: k[0], phone: k[1]).each_with_index do |vip_info, index|
        if index > 0
          next_phone = "#{vip_info.phone}0"
          loop_count = 0
          loop do
            vip_info.phone = next_phone
            if vip_info.valid?
              vip_info.save
              break
            elsif loop_count < 9
              next_phone = next_phone.next
              loop_count += 1
            else 
              break
            end
          end
        end
      end
    end
  end
end
