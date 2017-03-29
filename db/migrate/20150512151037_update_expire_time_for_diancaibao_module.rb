class UpdateExpireTimeForDiancaibaoModule < ActiveRecord::Migration
  def change
    count = 0
    Ddt::Shop.all.each do |shop|
      mod = shop.diancaibao_module
      mod.present? and mod.update(expired_at: shop.expiration_time)
      count += 1
      if count % 100 == 0
        puts "[UpdateExpireTimeForDiancaibaoModule] update #{count} shops"
      end
    end
  end
end
