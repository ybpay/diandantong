class FixTableZoneReservationPricePercent < ActiveRecord::Migration
  def change
    Ddt::TableZone.where(reservation_price_percent: nil).update_all(reservation_price_percent: 0)
  end
end
