class RenameIsLocalPrintedToGuestQueues < ActiveRecord::Migration
  def change
    rename_column :ddt_guest_queues, :is_local_print, :is_local_printed
  end
end
