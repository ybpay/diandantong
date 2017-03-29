module Ddt
  class AssetsAssetTag < Ddt::Base
    belongs_to :asset, class_name: "Ddt::Asset"
    belongs_to :asset_tag, class_name: "Ddt::AssetTag", counter_cache: :count
  end
end