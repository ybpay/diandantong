module Ddt
  class BatchCreateTableForm
    include ActiveModel::Validations
    attr_accessor :start_name, :count, :table_zone_id, :capacity, :branch

    validates_presence_of :start_name, :count, :table_zone_id, :capacity
    validates_numericality_of :count, :greater_than => 0, :less_than => 11
    validates_numericality_of :capacity, :greater_than => 0

    def initialize(hash = {})
      hash.each do |key, value|
        self.send(:"#{key}=", value)
      end
    end

    def to_key
      nil
    end

    def perform
      Ddt::Table.transaction do
        table_zone = branch.table_zones.find(table_zone_id)
        name = start_name
        count.to_i.times do
          table_zone.tables.create!(name: name, capacity: capacity)
          name = name.next
        end
      end
    end
  end
end
