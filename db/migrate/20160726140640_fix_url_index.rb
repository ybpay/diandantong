require 'octopus'
class FixUrlIndex < ActiveRecord::Migration
  def connection
    @connection ||= ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def with_proper_connection
    @connection = ActiveRecord::Base.octopus_establish_connection "impression_#{Rails.env}".to_sym
    yield
    @connection ||= ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def up
    with_proper_connection do
      ActiveRecord::Migration.change_column :ddt_js_errors, :url, :string, limit: 1024
      ActiveRecord::Migration.add_index :ddt_js_errors, :url
    end
  end

  def down
  end
end
