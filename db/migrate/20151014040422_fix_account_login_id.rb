class FixAccountLoginId < ActiveRecord::Migration
  def change
  	Ddt::Shop.find_each do |shop|
		shop.accounts.each do |account|
			unless account.login_id.start_with?(shop.slug)
				puts "login id of #{account.login_id} is not like shop slug #{shop.slug}"
				account.save!
			end
		end
	end
  end
end
