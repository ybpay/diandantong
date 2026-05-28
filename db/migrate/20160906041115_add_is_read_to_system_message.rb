class AddIsReadToSystemMessage < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_system_messages, :is_read
      add_column :ddt_system_messages, :is_read, :boolean, default: false
    end
    unless column_exists? :ddt_accounts, :unread_msg_count
      add_column :ddt_accounts, :unread_msg_count, :integer, default: 0
    end
    total = Ddt::Account.count
    count = 0
    Ddt::Account.find_each do |account|
      account.reset_msg_count
      count += 1
      if count % 100 == 0
        puts "#{count}/#{total} finished reset_msg_count"
      end
    end
  end

  def down
    remove_column :ddt_system_messages, :is_read if column_exists? :ddt_system_messages, :is_read
    remove_column :ddt_accounts, :unread_msg_count if column_exists? :ddt_accounts, :unread_msg_count
  end
end
