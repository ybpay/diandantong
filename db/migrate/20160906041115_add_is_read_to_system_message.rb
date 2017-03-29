class AddIsReadToSystemMessage < ActiveRecord::Migration
  def connection
    @connection ||= ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def with_proper_connection
    @connection = ActiveRecord::Base.octopus_establish_connection "impression_#{Rails.env}".to_sym
    yield
    @connection = ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def up
    with_proper_connection do 
      unless ActiveRecord::Migration.column_exists? :ddt_system_messages, :is_read
        ActiveRecord::Migration.add_column :ddt_system_messages, :is_read, :boolean, default: false 
      end
    end
    unless ActiveRecord::Migration.column_exists? :ddt_accounts, :unread_msg_count
      ActiveRecord::Migration.add_column :ddt_accounts, :unread_msg_count, :integer, default: 0
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
    with_proper_connection do 
      ActiveRecord::Migration.remove_column :ddt_system_messages, :is_read if ActiveRecord::Migration.column_exists? :ddt_system_messages, :is_read
    end
    ActiveRecord::Migration.remove_column :ddt_accounts, :unread_msg_count if ActiveRecord::Migration.column_exists? :ddt_accounts, :unread_msg_count
  end
end
