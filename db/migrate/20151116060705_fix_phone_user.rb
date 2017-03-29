class FixPhoneUser < ActiveRecord::Migration
  def change

    Ddt::BaseUser.where(vip_info_id: nil).find_each do |user|
      phone = user.phone
      if phone.present?
        vips = Ddt::VipInfo.where(phone: phone)
        if vips.size == 0
          puts "vip not found, phone:  #{phone}, base_user: #{phone_user.id}"
          user.send :create_default_vip_info
          next
        end

        if vips.size > 1
          puts "multiple vip found:"
          p vips
        end

        vip = vips[0]
        user.update_columns(vip_info_id: vip.id)
      else
        puts "User #{user.id}#{user.type}, phone is blank"
        user.send :create_default_vip_info
      end
    end

    change_column :ddt_base_users, :vip_info_id, :integer, :index=> true, :null => false

  end

end
