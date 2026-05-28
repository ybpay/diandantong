class FixLocation < ActiveRecord::Migration
  def self.up
    unless index_exists? :ddt_locations, [:owner_id, :owner_type, :updated_at], name: "owner_location_index"
      add_index :ddt_locations, [:owner_id, :owner_type, :updated_at], name: "owner_location_index"
    end

    if index_exists? :ddt_locations, :owner_id
      remove_index :ddt_locations, :owner_id
    end
  end

  def self.down
    unless index_exists? :ddt_locations, :owner_id
      add_index :ddt_locations, :owner_id
    end

    if index_exists? :ddt_locations, [:owner_id, :owner_type, :updated_at], name: "owner_location_index"
      remove_index :ddt_locations, name: "owner_location_index"
    end
  end
end
