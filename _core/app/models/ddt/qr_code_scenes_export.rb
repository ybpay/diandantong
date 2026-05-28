module Ddt
  class QrCodeScenesExport

    #
    # 导出桌贴
    #
    def self.export_table_sticker(qr_code_scenes, branch, version=:h)
      return nil if qr_code_scenes.blank?

      shop = nil
      tmp_zip_file = Tempfile.new_in_project("export_qr_codes", ".zip")
      file_compressor = Ddt::FileCompress.new(tmp_zip_file.path)

      # download logo
      # logo_path = branch.image.thumb.to_s
      # if logo_path == branch.image.default_url
      #   logo_path = default_branch_logo_path
      # else
      #   logo_tmp_file = Tempfile.new_in_project("branch_logo", ".png")
      #   open(logo_tmp_file.path, 'wb') do |file|
      #     file << open(logo_path).read
      #   end
      #   logo_path = logo_tmp_file.path
      # end

      if version == :original
        qr_code_scenes.each_with_index do |q, index|
          qr_code_tmp_file = Tempfile.new_in_project((q.owner.name rescue "qrcode_#{index}"), ".png")
          # download qr_code file
          open(qr_code_tmp_file.path, 'wb') do |file|
            file << q.url.file.download
          end
          file_compressor.compress_file(qr_code_tmp_file.path)
          qr_code_tmp_file.destroy
        end
        file_compressor.finish
        return tmp_zip_file
      end

      qr_code_scenes.each do |q|
        shop ||= q.shop
        qr_code_tmp_file = Tempfile.new_in_project("qr_code_scene", ".png")

        # download qr_code file
        open(qr_code_tmp_file.path, 'wb') do |file|
          file << open(q.url.url).read
        end

        composite_file_name = q.owner.name rescue "composite"

          # label 的对齐需要先把文字转换成图，然后获取其宽度，再计算位置
          # 横版
          if version == :h
            composite_tmp_file = Tempfile.new_in_project(composite_file_name, ".png")
            Ddt::ImageUtil.render_composite_image2(composite_tmp_file.path, table_sticker_bg_path(shop, version)) do |bg_image|
              left_align_pos = 144

              # 门店大字
              text = (branch.name rescue "unknow")
              bg_image = Ddt::ImageUtil.draw_label(
                  bg_image,
                  text: text,
                  gravity: 'northEast',
                  horizontal_shift: 469 - text_width(text, 60)/2.0,
                  vertical_shift: 63,
                  font: '_backend/public/fonts/HYQiHei-55S.otf',
                  size: '60',
                  color: '#ffffff'
              )

              # 二维码
              bg_image = Ddt::ImageUtil.draw_image(
                  bg_image,
                  path: qr_code_tmp_file.path,
                  width: 332,
                  height: 332,
                  margin_left: 307,
                  margin_top: 459
              )

              text = (q.owner.name rescue "unknow")
              bg_image = Ddt::ImageUtil.draw_label(
                  bg_image,
                  text: text,
                  gravity: 'northWest',
                  horizontal_shift: 469 - text_width(text, 80)/2.0,
                  vertical_shift: 63,
                  font: '_backend/public/fonts/HYQiHei-55S.otf',
                  size: '80',
                  color: '#ffffff'
              )

              # 点单通 LOGO 或 OEM 文字
              if shop.is_oem?
                text = shop.support_brand_name
                bg_image = Ddt::ImageUtil.draw_label(
                  bg_image,
                  text: text,
                  gravity: 'northWest',
                  horizontal_shift: 469 - text_width(text, 30)/2.0,
                  vertical_shift: 1133,
                  font: '_backend/public/fonts/HYQiHei-55S.otf',
                  size: '30',
                  color: '#ffffff'
                )
              end

              #  自定义行一
              text = branch.table_sticker_custom_line1
              if text.present?
                bg_image = Ddt::ImageUtil.draw_label(
                  bg_image,
                  text: text,
                  gravity: 'northEast',
                  horizontal_shift: 469 - text_width(text, 88)/2.0,
                  vertical_shift: 500,
                  font: '_backend/public/fonts/HYQiHei-55S.otf',
                  size: '88',
                  color: '#ffffff'
                )
              end

              # 自定义二
              text = branch.table_sticker_custom_line2
              if text.present?
                bg_image = Ddt::ImageUtil.draw_label(
                  bg_image,
                  text: text,
                  gravity: 'northEast',
                  horizontal_shift: 469 - text_width(text, 88)/2.0,
                  vertical_shift: 650,
                  font: '_backend/public/fonts/HYQiHei-55S.otf',
                  size: '88',
                  color: '#ffffff'
                )
              end

                # bg_image = Ddt::ImageUtil.draw_label(
                #     bg_image,
                #     text: '号桌',
                #     gravity: 'northWest',
                #     horizontal_shift: 660 + text_width(text, 190)/2.0,
                #     vertical_shift: 1829,
                #     font: '_backend/public/fonts/lantinghei.ttf',
                #     size: '66',
                #     color: '#FFFFFF'
                # )
              bg_image
            end
            qr_code_tmp_file.destroy
            file_compressor.compress_file(composite_tmp_file.path)
            composite_tmp_file.destroy
          else
            # 桌号、Logo中轴线X=470 桌号字号48，上边沿线Y=790
            # Logo上边沿Y=867
            # 二维码左上角Y=277 X=211
            # 右下角Y=775 X=711
            # 商家名称 Y=70 X=277, 字号48
            bg_path = table_sticker_bg_path(shop, version)


            composite_tmp_file = Tempfile.new_in_project("#{composite_file_name}", ".png")
            font_color = '#ffffff'
            Ddt::ImageUtil.render_composite_image2(composite_tmp_file.path, bg_path) do |bg_image|
              # 门店大字
              text = (branch.name rescue "unknow")
              bg_image = Ddt::ImageUtil.draw_label(
                  bg_image,
                  text: text,
                  gravity: 'northWest',
                  horizontal_shift: 80,
                  vertical_shift: 40,
                  font: '_backend/public/fonts/HYQiHei-55S.otf',
                  size: '48',
                  color: font_color
              )

              # 二维码
              bg_image = Ddt::ImageUtil.draw_image(
                  bg_image,
                  path: qr_code_tmp_file.path,
                  width: 320,
                  height: 320,
                  margin_left: 596 - (320/2.0),
                  margin_top: 480
              )

              # 桌台号
              text = (q.owner.name rescue "unknow")
              bg_image = Ddt::ImageUtil.draw_label(
                  bg_image,
                  text: text,
                  gravity: 'northEast',
                  horizontal_shift: 40,
                  vertical_shift: 40,
                  font: '_backend/public/fonts/HYQiHei-55S.otf',
                  size: '120',
                  color: font_color
              )

              #  自定义行一
              text = branch.table_sticker_custom_line1
              if text.present?
                bg_image = Ddt::ImageUtil.draw_label(
                  bg_image,
                  text: text,
                  gravity: 'northWest',
                  horizontal_shift: 596 - text_width(text, 88)/2.0,
                  vertical_shift: 1080,
                  font: '_backend/public/fonts/HYQiHei-55S.otf',
                  size: '88',
                  color: font_color
                )
              end

              # 自定义二
              text = branch.table_sticker_custom_line2
              if text.present?
                bg_image = Ddt::ImageUtil.draw_label(
                  bg_image,
                  text: text,
                  gravity: 'northWest',
                  horizontal_shift: 596 - text_width(text, 88)/2.0,
                  vertical_shift: 1210,
                  font: '_backend/public/fonts/HYQiHei-55S.otf',
                  size: '88',
                  color: font_color
                )
              end

              # 点单通 LOGO 或 OEM 文字
              if shop.is_oem?
                text = shop.support_brand_name
                bg_image = Ddt::ImageUtil.draw_label(
                  bg_image,
                  text: text,
                  gravity: 'southWest',
                  horizontal_shift: 596 - text_width(text, 40)/2.0,
                  vertical_shift: 40,
                  font: '_backend/public/fonts/HYQiHei-55S.otf',
                  size: '40',
                  color: font_color
                )
              end
              bg_image
            end
            qr_code_tmp_file.destroy
            file_compressor.compress_file(composite_tmp_file.path)
            composite_tmp_file.destroy
          end
      end

      # logo_tmp_file.destroy if logo_tmp_file

      file_compressor.finish
      return tmp_zip_file
    end

    # 把文字转换成图片
    # def self.draw_text_image(options)
    #   # /usr/bin/convert -fill black -size 40x40 label:$NUMBERS -transparent white -trim  numbers.gif
    #   bg_image = MiniMagick::Image.create('png') do |c|
    #   # bg_image.combine_options do |c|
    #     c.fill options[:color]
    #     c.size '1000x1000'
    #     c.label options[:text]
    #     c.transparent 'white'
    #     c.trim
    #   end
    #   # bg_image.write Tempfile.new_in_project('text_image','png')
    #   bg_image
    # end

    def self.export_queue_qr_codes(queue_qr_codes, outfile)
      export_routine queue_qr_codes, outfile do |queue_qr_code|
        download_qr_code(queue_qr_code.url) do |qr_code_file|
          composite_file_name = "#{queue_qr_code.branch.name}" rescue "#{queue_qr_code.id}"
          composite_tmp_file = Tempfile.new_in_project(composite_file_name, ".png")
          shop = queue_qr_code.shop
          branch = queue_qr_code.branch
          Ddt::ImageUtil.render_composite_image2(composite_tmp_file.path, queue_poster_bg_path(shop)) do |bg_image|
            # 二维码
            bg_image = Ddt::ImageUtil.draw_image(
                bg_image,
                path: qr_code_file.path,
                width: 1600,
                height: 1590,
                margin_left: 1600,
                margin_top: 2460
            )

            # 门店名称
            text = (branch.name rescue "unknow")
            bg_image = Ddt::ImageUtil.draw_label(
                bg_image,
                text: text,
                gravity: 'northWest',
                horizontal_shift: 3300,
                vertical_shift: 80,
                font: '_backend/public/fonts/HYQiHei-55S.otf',
                size: '180',
                color: '#FFFFFF'
            )
            bg_image
          end
          composite_tmp_file
        end
      end
    end

    #
    # 导出门贴
    #
    def self.export_door_stickers(branch_qr_codes, outfile)
      export_routine branch_qr_codes, outfile do |branch_qr_code|
        download_qr_code(branch_qr_code.url) do |qr_code_file|
          composite_file_name = "#{branch_qr_code.branch.name}" rescue "#{branch_qr_code.id}"
          composite_tmp_file = Tempfile.new_in_project(composite_file_name, ".png")
          shop = branch_qr_code.shop
          branch = branch_qr_code.branch
          Ddt::ImageUtil.render_composite_image2(composite_tmp_file.path, door_sticker_bg_path) do |bg_image|
            # 二维码
            bg_image = Ddt::ImageUtil.draw_image(
                bg_image,
                path: qr_code_file.path,
                width: 624,
                height: 624,
                margin_left: 1100,
                margin_top: 510
            )

            # 门店名称
            text = (branch.name rescue "unknow")
            bg_image = Ddt::ImageUtil.draw_label(
                bg_image,
                text: text,
                gravity: 'northWest',
                horizontal_shift: 1150,
                vertical_shift: 1150,
                font: '_backend/public/fonts/lantinghei_ex.ttf',
                size: '66',
                color: '#000000'
            )
            bg_image
          end
          composite_tmp_file
        end
      end
    end

    #
    # 导出快餐海报
    #
    def self.export_fastfood_stickers(branch_qr_codes, outfile)
      export_routine branch_qr_codes, outfile do |branch_qr_code|
        download_qr_code(branch_qr_code.url) do |qr_code_file|
          composite_file_name = "#{branch_qr_code.branch.name}" rescue "#{branch_qr_code.id}"
          composite_tmp_file = Tempfile.new_in_project(composite_file_name, ".png")
          shop = branch_qr_code.shop
          branch = branch_qr_code.branch
          Ddt::ImageUtil.render_composite_image2(composite_tmp_file.path, fastfood_sticker_bg_path) do |bg_image|
            # 二维码
            bg_image = Ddt::ImageUtil.draw_image(
                bg_image,
                path: qr_code_file.path,
                width: 1700-110,
                height: 2310-740,
                margin_left: 110,
                margin_top: 740
            )

            # 门店名称
            text = (branch.name rescue "unknow")
            bg_image = Ddt::ImageUtil.draw_label(
                bg_image,
                text: text,
                gravity: 'northWest',
                horizontal_shift: 2562,
                vertical_shift: 2165,
                font: '_backend/public/fonts/微软雅黑.ttf',
                size: '128',
                color: '#f34b3f'
            )
            bg_image
          end
          composite_tmp_file
        end
      end
    end

    private

    def self.export_routine(object_or_array, outfile)
      return nil if object_or_array.blank?
      tmp_zip_file = Tempfile.new_in_project(outfile, ".zip")
      file_compressor = Ddt::FileCompress.new(tmp_zip_file.path)

      if object_or_array.is_a? Array
        object_or_array.each do |object|
          single_outfile = (yield object)
          file_compressor.compress_file(single_outfile.path)
          single_outfile.destroy
        end
      else
        single_outfile = yield object_or_array
        file_compressor.compress_file(single_outfile.path)
        single_outfile.destroy
      end
      file_compressor.finish
      tmp_zip_file
    end

    def self.download_qr_code(url)
      qr_code_tmp_file = Tempfile.new_in_project('qr_code_scene', '.png')

      # download qr_code file
      open(qr_code_tmp_file.path, 'wb') do |file|
        file << open(url).read
      end

      if block_given?
        result = yield qr_code_tmp_file
        qr_code_tmp_file.destroy
        result
      else
        qr_code_tmp_file
      end
    end

    def self.table_sticker_bg_path(shop = nil, version)
      if shop.present?
        if shop.is_oem?
          bg_pic_name = (version == :h) ? 'table_sticker_bg2.png' : 'table_sticker_v_bg2_1.png'
        else
          bg_pic_name = (version == :h) ? 'table_sticker_bg.png' : 'table_sticker_v_bg1_1.png'
        end
      end
      if bg_pic_name.is_a? Array
        bg_pic_name.map{|bg| Rails.root.to_s + '/_backend/app/assets/images/ddt/images/' + bg}
      else
        Rails.root.to_s + '/_backend/app/assets/images/ddt/images/' + bg_pic_name
      end

    end

    def self.text_width(text, point)
      halfs = 0
      text.each_byte do |c|
        halfs += 1 unless c >= 128
      end
      (text.length - (halfs / 2.0)) * point
    end

    def self.queue_poster_bg_path(shop)
      if shop.present?
        if shop.is_oem?
          bg_pic_name = 'queue_poster.png' # 以后有的时候需要更换
        else
          bg_pic_name = 'queue_poster.png'
        end
      end
      Rails.root.to_s + '/_backend/app/assets/images/ddt/images/' + bg_pic_name
    end

    def self.door_sticker_bg_path
      Rails.root.to_s + '/_backend/app/assets/images/ddt/images/door_sticker_bg.png'
    end

    def self.fastfood_sticker_bg_path
      Rails.root.to_s + '/_backend/app/assets/images/ddt/images/fastfood_sticker_bg.png'
    end


  end
end
