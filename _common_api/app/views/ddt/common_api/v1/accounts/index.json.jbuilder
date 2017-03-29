json.array! @accounts do |account|
  json.partial! partial: '/ddt/common_api/v1/accounts/detail', locals: { account: account }
end
