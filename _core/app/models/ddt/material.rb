# encoding: utf-8
module Ddt
  class Material < Ddt::Base
    replicated_model


    MATERIAL_PROMOTION_TYPE = "promotion"
    MATERIAL_NEWS_TYPE = "news"
    MATERIAL_TEXT_TYPE = "text"
    MATERIAL_MUSIC_TYPE = "music"
    MATERIAL_TYPES = [MATERIAL_PROMOTION_TYPE, MATERIAL_NEWS_TYPE, MATERIAL_TEXT_TYPE, MATERIAL_MUSIC_TYPE]
    MSG_TYPES = [[I18n.t("material.text"), :text], [I18n.t("material.music"),:music], [I18n.t("material.news"),:news]]

    # relationships
    include Ddt::BelongsToShop
    has_many :articles, -> { order("position ASC") }, dependent: :destroy, as: :owner, class_name: 'Ddt::Article'


    validates :material_name, :msg_type, presence: true, on: :update
    validates :content, presence: true, if: :is_text?
    validates :title, :music_url, presence: true, uri: true, if: :is_music?
    validates :material_name, uniqueness: { :scope=>:shop_id }, on: :update
    validates_associated :articles, if: :is_news?


    default_scope -> {order("created_at DESC")}

    before_save :remove_unused_attribute
    
    MATERIAL_TYPES.each do |m|
      define_method "is_#{m}?".to_sym do
        self.msg_type.to_sym == m.to_sym
      end
    end

    def self.valid_materials(all_materials)
      materials = []
      all_materials.each do |material|
        if material.valid?
          materials << material
        end
      end
      materials
    end




    private
    def remove_unused_attribute
      if is_text?
        title = nil
        description = nil
        music_url = nil
        hq_music_url = nil
        articles.delete_all unless articles.nil?
        articles = []
      elsif is_music?
        content = nil
        articles.delete_all unless articles.nil?
        articles = []
      elsif is_news?
        content = nil
        title = nil
        description = nil
        music_url = nil
        hq_music_url = nil
      end
    end


  end
end
