module Ddt
  class UploadedFile < Base
    include BelongsToShop
    include Ddt::CarrierWaveBridge
    mount_uploader :file, TempfileUploader
  end
end