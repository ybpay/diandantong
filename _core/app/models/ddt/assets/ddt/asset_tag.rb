module Ddt
  class AssetTag < Ddt::Base
    has_many :assets_asset_tags, class_name: "Ddt::AssetsAssetTag", dependent: :destroy
    has_many :assets, through: :assets_asset_tags, class_name: "Ddt::Asset"
    validates_presence_of :name

    def select_json
      { id: self.id, name: self.name }
    end

    def tag_json
      { id: self.name, text: self.name }
    end
  end
end