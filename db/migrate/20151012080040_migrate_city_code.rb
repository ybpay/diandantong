class MigrateCityCode < ActiveRecord::Migration
  def change
    puts "+++++++++++++[shop]++++++++++++++++"
    n = 0
    Ddt::Shop.find_each do |shop|
      city_code = Cncity.get_city_code(shop.address)
      shop.update_columns(city_code: city_code)
      n +=1
      puts "#{n}th, shopid: #{shop.id}" if n%100 == 0
    end

    puts "+++++++++++++[agent zone]++++++++++++++++"
    n = 0
    Ddt::AgentZone.find_each do |zone|
      city_code = Cncity.get_city_code(zone.full_name)
      zone.update_columns(city_code: city_code)
      n += 1
      puts "#{n}th, agentzone id: #{zone.id}" if n%100 == 0
    end
  end
end
