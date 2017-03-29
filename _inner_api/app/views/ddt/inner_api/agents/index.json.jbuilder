json.array! @agents do |agent|
  json.partial! partial: 'agent', locals: { agent: agent }
end