class AddIsLocalPrintToGeustQueue < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_guest_queues, :is_local_print
      add_column :ddt_guest_queues, :is_local_print, :boolean, defaut: false
    end
  end
end
