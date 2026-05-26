require 'file_size_validator'
module Ddt
  class Article < Ddt::Base
    include Ddt::BelongsToShop



    ARTICLE_SHOW_LINK = "article"
    SHOP_OR_BRANCH_LINK = "shop_or_branch"
    OUTSIDE_THE_WEB_LINK = "other_web_link"
    ARTICLE_TYPES = [Ddt::Article::ARTICLE_SHOW_LINK,  Ddt::Article::SHOP_OR_BRANCH_LINK, Ddt::Article::OUTSIDE_THE_WEB_LINK]

    acts_as_type :link_type, ARTICLE_TYPES, ARTICLE_TYPES.map{|t| I18n.t "activerecord.attributes.ddt/article.link_types.#{t}"}
    acts_as_list scope: [:owner_id, :owner_type]
    belongs_to :owner, polymorphic: true
    belongs_to :material, -> { joins(:articles).where("ddt_articles.owner_type = 'Ddt::Material'")}, foreign_key: 'owner_id', class_name: "Ddt::Material"
    set_shop_from :owner

 #   validates :title, presence: true
 #   validates :image, :file_size => { :maximum => 0.5.megabytes.to_i }

    mount_uploader :image, ArticleImageUploader

    scope :real, ->{ where(link_type: ARTICLE_SHOW_LINK)}
 #   validates :url, uri: true, if: :is_other_web_link?
    filter_urls_for :url

    # 在素材中的位置
    def relative_position
      if self.material
        position = self.material.articles.index(self)
        position.present? ? position + 1 : self.material.articles.count + 1
      else

      end
    end

    def article_url
      if link_type == ARTICLE_SHOW_LINK
        Ddt::LinkResource.new(shop: self.shop).article_whole_url(self)
      else
        url
      end
    end

    def link(version='only_ng', querys={})
      Ddt::LinkResource.new(shop: self.shop, querys: querys).article_whole_url(self)
    end

    def set_position(str)
      str = Integer(str) rescue str
      if str.is_a? Fixnum
        self.insert_at(str)
      else
        self.send(str)
      end
    end

    def select_json(version, querys={})
      { id: link(version, querys), name: title }
    end

    def description_decoder
      ::HTMLEntities.new.decode(ActionView::Base.full_sanitizer.sanitize(self.description))
    end

  end
end
