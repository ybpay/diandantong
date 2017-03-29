class RemovePositionToGuestQueue < ActiveRecord::Migration
  def change
    remove_column :ddt_guest_queues, :position, :integer
  end
end
