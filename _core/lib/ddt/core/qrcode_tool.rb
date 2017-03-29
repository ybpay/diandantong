require 'rqrcode_png'
module Ddt
  module QrcodeTool
    def self.generate_qrcode_image(url, width=250)
      RQRCode::QRCode.new( url, :size => 5, :level => :l ).to_img.resize(width, width)
    end
  end
end