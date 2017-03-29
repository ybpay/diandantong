module Ddt
  class UploadedFile < Base
    include BelongsToShop
    mount_uploader :file, TempfileUploader
  end
end