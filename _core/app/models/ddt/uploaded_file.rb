module Ddt
  class UploadedFile < Base
    include BelongsToShop
    include Ddt::Attachable
    attachable_one :file
  end
end