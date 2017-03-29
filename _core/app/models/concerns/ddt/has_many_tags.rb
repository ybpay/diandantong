module Ddt
  module HasManyTags
    extend ActiveSupport::Concern
    attr_accessor :tag_names_string
    included do
      has_many :tag_relations, class_name: "#{self.name.pluralize}Tag", dependent: :destroy
      has_many :tags, through: :tag_relations, class_name: "#{self.name}Tag"
      ids_string_for :tags

      before_save :set_tag_ids
    end

    def tag_names
      self.tags.map(&:name).join(',')
    end

    def tag_names=(names)
      @tag_names_string = names
    end

    def tag_type
      "#{self.class.name}Tag"
    end

    def saved_tags
      tags.map(&:tag_json)
    end

    def set_tag_ids
      unless tag_names_string.nil?
        if tag_names_string != ''
          branch_id = (self.is_a? Ddt::Branch) ? nil : self.branch_id
          self.tag_ids = tag_names_string.split(',').map do |name|
            tag = Ddt::Tag.find_or_create_by(name: name, type: tag_type, branch_id: branch_id, shop_id: self.shop_id)
            tag.id
          end
        else
          self.tag_ids = []
        end
      end
    end

  end
end
