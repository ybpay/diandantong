json.cache! [@current_shop, @current_branch], expires_in: 1.day do
  json.partial! partial: '/ddt/common_api/v1/branches/branch', locals: { branch: @current_branch }
end
json.webpos_autoprinter_configed @current_branch.webpos_printer_configed?
