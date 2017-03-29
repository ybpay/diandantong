class FixDiancaibaoExpiredAt < ActiveRecord::Migration
  def change
    Ddt::Shop.find_each do |shop|
      shop.diancaibao_module.update(expired_at: shop.expiration_time)
    end
  end
end
