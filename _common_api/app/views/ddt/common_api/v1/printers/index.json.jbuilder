json.array! @printers do |printer|
    json.extract! printer, :id, :name, :number, :enable
end