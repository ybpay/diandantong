module Ddt
  class Asset < Ddt::Base
    belongs_to :shop, class_name: 'Ddt::Shop'
    belongs_to :branch, -> { with_discarded }, class_name: 'Ddt::Branch'
    has_many :assets_asset_tags, class_name: 'Ddt::AssetsAssetTag', dependent: :destroy
    has_many :asset_tags, through: :assets_asset_tags, class_name: "Ddt::AssetTag"
    # validations
    validates_presence_of :attachment

    # callbacks
    before_save :update_asset_attributes

    #scope
    scope :global, ->(bool=true){where(is_global: bool)}
    default_scope ->{ order(created_at: :desc)}
    ids_string_for :asset_tags

    def asset_tag_names
      self.asset_tags.map(&:name).join(',')
    end

    def asset_tag_names=(names)
      self.asset_tag_ids = names.split(',').map do |name|
        tag = Ddt::AssetTag.find_or_create_by(name: name)
        tag.id
      end
    end

    private
    def update_asset_attributes
      if attachment.present? && attachment_changed?
        self.content_type = attachment.file.content_type
        self.file_size = attachment.file.size
      end
    end
  end
end