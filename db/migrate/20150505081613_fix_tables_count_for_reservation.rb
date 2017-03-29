class FixTablesCountForReservation < ActiveRecord::Migration
  def change
    Ddt::TableZone.where(tables_count_for_reservation: nil).update_all(tables_count_for_reservation: 0)
  end
end
