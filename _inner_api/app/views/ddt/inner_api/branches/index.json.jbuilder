json.array! @branches do |branch|
  json.partial! partial: 'branch', locals: { branch: branch }
end