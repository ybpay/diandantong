module Ddt
  module Backend
    module HomeHotLinksHelper
      def home_hot_link_icon(home_hot_link)
        if home_hot_link.icon.present? && home_hot_link.icon_background_color.present? && home_hot_link.image.blank?
          content_tag(:span, class: 'backend-home-hot-link-icon', style: "background-color:#{home_hot_link.icon_background_color}") do
            tag(:icon, class: "fa #{home_hot_link.icon}")
          end
        end
      end

      def home_hot_link_image(home_hot_link)
        if home_hot_link.image.attached?
          image_tag(home_hot_link.image_variant(:thumb), class: 'backend-home-hot-link-icon')
        end
      end
    end
  end
end