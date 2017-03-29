# encoding: utf-8
module Ddt
  module Backend
    module MaterialsHelper
      def material_type_fa(type)
        return content_tag(:i,'',class:'fa fa-font') if type == 'text'
        return content_tag(:i,'',class:'fa fa-picture-o') if type == "news"
        return content_tag(:i,'',class:'fa fa-music') if type == "music"
      end

      def check_valid?
        return true if 'materials' == controller_name && 'index' == action_name
        false
      end

      def is_edit_material?
        return true if (['new','create', 'edit','update','destroy'].include? action_name)
        false
      end

      def first_step(material)
        material.blank? || material.id.blank?
      end

      def fa_pencil
        content_tag(:i,'',class:'fa fa-pencil')
      end
      def article_edit_link(shop,material,article)
        if article.id == nil
          link_to(edit_backend_shop_material_article_path(shop,material,'_'),method: 'get', remote: true) do
            fa_pencil
          end
        else
          link_to(edit_backend_shop_material_article_path(shop,material,article),method: 'get', remote: true) do
            fa_pencil
          end
        end
      end

      def fa_trash
        content_tag(:i,'',class:'fa fa-trash')
      end
      def article_del_link(shop, material, article)
        if article.id == nil
          ''
          # link_to('') do
          #   fa_trash
          # end
        else
          link_to(backend_shop_material_article_path(shop,material,article), method: 'delete', remote: true) do
            fa_trash
          end
        end
      end

      def avoid_nil_material_name(name)
        return '名字' if name.blank?
        name
      end

      def avoid_nil_material_content(content)
        return '内容' if content.blank?
        clear_str content
      end

      def avoid_nil_material_title(title)
        return '标题' if title.blank?
        return clear_str title
      end

      def avoid_nil_material_music_url(music_url)
        return '音乐网址' if music_url.blank?
        return music_url
      end

      def avoid_nil_material_hq_music_url(hq_music_url)
        return '高清音乐网址' if hq_music_url.blank?
        return hq_music_url
      end

      def avoid_nil_material_description(description)
        return '描述' if description.blank?
        return clear_str description
      end

      def avoid_nil_material_article_cover(imgurl)
        return '封面图' if imgurl.blank? || imgurl.include?('missing')
        image_tag imgurl,  width: "100%", height: '100%'
      end

      def avoid_nil_material_article_smpic(imgurl)
        return '缩略图' if imgurl.blank? || imgurl.include?('missing')
        image_tag imgurl,  width: "100%", height: '100%'
      end

      def avoid_nil_material_article_title(title)
        return '标题' if title.blank?
        clear_str title
      end

      def clear_str(str)
        strip_tags(str).gsub(/&\w+;/i,"")
      end
    end
  end
end
