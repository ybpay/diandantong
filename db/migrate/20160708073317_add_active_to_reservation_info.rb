class AddActiveToReservationInfo < ActiveRecord::Migration
  def change
    add_column :ddt_reservation_infos, :active, :boolean, default: true
  end
end
