json.cache! @combos, expires_in: 1.day do
  json.array! @combos do |combo|
    json.partial! partial: '/ddt/common_api/v1/combos/base', locals: { combo: combo }
  end
end
