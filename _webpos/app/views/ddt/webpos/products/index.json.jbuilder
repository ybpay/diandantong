# 修复 products#index (ActionView::Template::Error) "File name too long @ dir_s_mkdir - /root/ruby-workspace/diandan..
# franky 写的缓存键似乎不起作用。如果直接缓存关系，可以减少数据库查询，后面让他来调试优化吧。

json.cache! Digest::MD5.hexdigest(@products.map(&:cache_key).join), expires_in: 1.day do
  json.partial! partial: '/ddt/webpos/products/product', collection: @products, as: :product
end