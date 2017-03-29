require 'octopus'
class FixLocation < ActiveRecord::Migration

  def connection
    @connection ||= ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def with_proper_connection
    @connection = ActiveRecord::Base.octopus_establish_connection "impression_#{Rails.env}".to_sym
    yield
    @connection ||= ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end


  def self.up
    with_proper_connection do
      unless ActiveRecord::Migration.index_exists? :ddt_locations, [:owner_id, :owner_type, :updated_at], name: "owner_location_index"
        ActiveRecord::Migration.add_index :ddt_locations, [:owner_id, :owner_type, :updated_at], name: "owner_location_index"
      end

      if ActiveRecord::Migration.index_exists? :ddt_locations, :owner_id
        ActiveRecord::Migration.remove_index :ddt_locations, :owner_id
      end
    end
  end

  def self.down
    with_proper_connection do
      unless ActiveRecord::Migration.index_exists? :ddt_locations, :owner_id
        ActiveRecord::Migration.add_index :ddt_locations, :owner_id
      end

      if ActiveRecord::Migration.index_exists? :ddt_locations, [:owner_id, :owner_type, :updated_at], name: "owner_location_index"
        ActiveRecord::Migration.remove_index :ddt_locations, name: "owner_location_index"
      end
    end

  end
end
