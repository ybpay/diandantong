json.partial! partial: 'base'
json.bill @list.content
json.items @list.items do |entry|
  json.extract! entry, :name, :total, :queueing, :accepted, :accepted_rate, :rejected, :rejected_rate
end