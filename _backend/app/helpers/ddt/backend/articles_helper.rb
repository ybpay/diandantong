# encoding: utf-8
module Ddt
  module Backend
    module ArticlesHelper
      def is_edit?
        params[:action] == 'edit'
      end

      def is_create?
        params[:action] == 'create'
      end

      def is_update?
        params[:action] == 'update'
      end

      def get_article_url(article, index)
        if not article.pic_url.nil?
          article.pic_url
        elsif not article.image.nil?
          if index == 0
            article.image_variant(:medium)
          else
            article.image_variant(:thumb)
          end
        else
          ""
        end
      end

      def get_article_position_select_option(record_list)
        options = [["置顶", "move_to_top"]]
        record_list.each_with_index do |record_item, index|
          options << ["第#{index+1}位", index+1]
        end
        options << ["埋底", "move_to_bottom"]
      end
    end

  end
end