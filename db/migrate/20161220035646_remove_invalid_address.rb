class RemoveInvalidAddress < ActiveRecord::Migration
  def up
    Ddt::Address.where("latitude is NULL or longitude is NULL").find_each do |address|
      if address.base_user.present?
        puts "#{address.base_user_id} is a #{address.base_user.type}"
        if address.base_user.is_a? Ddt::User
          puts "going to destroy address #{address.id}"
          address.destroy
        end
      else
        address.destroy
      end
    end
  end

  def down
  end
end
