#encoding: utf-8
module Ddt
  module ImageUtil

    # over_images = [{
    #   path: path/to/image,
    #   width: width of image,
    #   height: height of image,
    #   margin_left: margin bg_image left,
    #   margin_top: margin bg_image top
    # }]
    #
    # over_labels = [{
    #   text: whatever text,
    #   gravity: refer direction(center, southWest...),
    #   horizontal_shift: 10,
    #   vertical_shift: 10
    # }]
    def self.render_composite_image(composite_image_path, bg_image_path, over_images, over_labels=[])
      bg_image   = MiniMagick::Image.new(bg_image_path)

      over_images.each do |over_image|
        path = over_image[:path]
        image = MiniMagick::Image.open(path)
        image.resize "#{over_image[:width]}x#{over_image[:height]}"
        bg_image = bg_image.composite(image) do |c|
          c.compose "Over"
          c.geometry "+#{over_image[:margin_left]}+#{over_image[:margin_top]}"
        end
      end

      bg_image = draw_labels(bg_image, over_labels) if over_labels.size > 0
      bg_image.write composite_image_path
    end

    def self.draw_labels(image, labels)
      image.combine_options do |c|
        c.font Rails.root.join("_backend/public/fonts/msyhbd.ttf").to_s
        c.pointsize '50'
        c.fill "#F34B3F"
        labels.each do |label|
          c.gravity label[:gravity]
          c.draw 'text '+label[:horizontal_shift].to_s+', '+label[:vertical_shift].to_s+'"'+label[:text]+'"'
        end
      end
      return image
    end

    def self.render_composite_image2(composite_image_path, bg_image_path)
      bg_image = MiniMagick::Image.open(bg_image_path)
      if block_given?
        bg_image = yield bg_image
      end
      bg_image.write composite_image_path
    end

    def self.draw_image(image, options)
      path = options[:path]
      new_image = MiniMagick::Image.open(path)
      new_image.resize "#{options[:width]}x#{options[:height]}"
      image = image.composite(new_image) do |c|
        c.compose "Over"
        c.geometry "+#{options[:margin_left]}+#{options[:margin_top]}"
      end
      return image
    end

    def self.draw_label(image, options)
      image.combine_options do |c|
        c.font Rails.root.join(options[:font]).to_s
        c.pointsize options[:size]
        c.gravity options[:gravity]
        c.fill options[:color]
        c.draw 'text ' + options[:horizontal_shift].to_s + ', ' + options[:vertical_shift].to_s + '"' +options[:text]+'"'
      end
      return image
    end

  end
end

