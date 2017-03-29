# encoding:utf-8
module Ddt
  module Backend
    module ProductsHelper
      def shelf_status_label(product)
        if !product.on_shelf?
          if product.estimate_clear?
            content_tag(:span, "已下架 , 已估清", class: "label label-default")
          else
            content_tag(:span, "已下架", class: "label label-default")
          end
        else
           if product.estimate_clear?
             content_tag(:span, "已估清", class: "label label-default")
           end
        end
      end

      def images_label(product)
        if product.master_images.size == 0
          link_to '上传', [:backend, @current_shop, @current_branch, product, product.master, :variant_images]
        else
          product.master_images.map do |image|
            content_tag :a, class: 'product-image' do
              content_tag(:icon, '', class: 'fa fa-image') + \
              content_tag(:div, class: 'content') do
                image_tag image.attachment.rect_normal.url
              end
            end
          end.join("&nbsp;").html_safe
        end
      end

      def tags_label(tag_names)
        html = ""
        if tag_names.present?
          tag_names.split(',').each do |tag_name|
            html += "<span class='label label-primary'><i class='fa fa-tag'></i> #{tag_name} </span> "
          end
        end
        html
      end

    end
  end
end
