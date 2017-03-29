json.cache! @current_shop, expires_in: 1.day do
  json.extract! @current_shop, :id, :name, :currency, :slug, :card_key, :use_shop_name_for_queue, :enable_foreign
  if @current_shop.agent.present?
    json.domain @current_shop.agent.domain_url
  end
  json.subtract_reasons @current_shop.subtract_reasons.map(&:name)
end
