json.extract! @table, :id, :name, :name_with_zone
json.is_idle @table.is_idle?
