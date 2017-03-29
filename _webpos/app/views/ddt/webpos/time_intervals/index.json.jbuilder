json.array! @time_intervals do |time_interval|
  json.extract! time_interval, :id, :name
  json.start time_interval.start.strftime('%H:%M')
  json.end time_interval.end.strftime('%H:%M')
end
