class FixShopCardKey < ActiveRecord::Migration
  def change
    Ddt::Shop.where("length(card_key) < 12").find_each do |shop|
      shop.update_column(:card_key, "#{'0'*(12 - shop.card_key.length)}#{shop.card_key}")
    end
  end
end
