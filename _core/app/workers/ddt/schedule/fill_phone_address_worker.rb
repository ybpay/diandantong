# encoding: utf-8
module Ddt
  module Schedule
    class FillPhoneAddressWorker < Ddt::Schedule::Base

      def perform
        Ddt::Account.joins(:shop).where("built_in = 1 and city_code='000000' and ddt_accounts.phone IS NOT NULL").find_each do |account|
          phone_address = account.look_up_phone_address
          next if phone_address.blank?
          puts "start to migrate phone_address for #{phone_address} of shop #{account.shop_id}"
          account.update_column(:phone_address, phone_address)
          city_code = Cncity.get_city_code(phone_address)
          account.shop.update_columns(address: phone_address, city_code: city_code)
        end
      end
    end
  end
end
