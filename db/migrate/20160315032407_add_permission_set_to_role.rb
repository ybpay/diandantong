class AddPermissionSetToRole < ActiveRecord::Migration
  def up
    add_column :ddt_roles, :permission_set, :text unless column_exists? :ddt_roles, :permission_set
    add_column :ddt_roles, :description, :text unless column_exists? :ddt_roles, :description
    add_column :ddt_roles, :type, :string unless column_exists? :ddt_roles, :type
    execute <<-SQL
      update ddt_roles r
      SET r.type = case r.name
      when "admin"            then "Ddt::Role::Admin"
      when "boss"             then "Ddt::Role::Boss"
      when "worker"           then "Ddt::Role::Worker"
      when "deliveryman"      then "Ddt::Role::Deliveryman"
      when "cook"             then "Ddt::Role::Cook"
      when "chef"             then "Ddt::Role::Chef"
      when "waiter"           then "Ddt::Role::Waiter"
      when "cashier"          then "Ddt::Role::Cashier"
      when "vip_info_manager" then "Ddt::Role::VipInfoManager"
      when "queue_waiter"     then "Ddt::Role::QueueWaiter"
      when "accountant"       then "Ddt::Role::Accountant"
      else "Ddt::Role::Custom"
      end;
    SQL
  end

  def down
    remove_column :ddt_roles, :permission_set, :text if column_exists? :ddt_roles, :permission_set
    remove_column :ddt_roles, :description, :text if column_exists? :ddt_roles, :description
    remove_column :ddt_roles, :type, :string if column_exists? :ddt_roles, :type
  end
end
