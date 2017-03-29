json.array! @shops do |shop|
  json.partial! partial: 'shop', locals: { shop: shop }
end