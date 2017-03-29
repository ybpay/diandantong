json.cache! [@current_shop], expires_in: 1.day do
  json.array! @current_shop.weixin_pages do |weixin_page|
    json.extract! weixin_page, :template_type, :url
  end
end