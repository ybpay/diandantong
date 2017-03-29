class Ddt::SaleDataUploaderConfig < Settingslogic
  source "#{Rails.root}/config/sale_data_uploader_config.yml"
  namespace Rails.env
end