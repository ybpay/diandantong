# Transitional bridge from CarrierWave mount_uploader to ActiveStorage.
#
# Replaces `mount_uploader :field, UploaderClass` with `has_one_attached :field`
# and provides backward-compatible URL methods so existing code continues to work.
#
# Usage (same as before):
#   mount_uploader :image, ShopImageUploader
#
# The UploaderClass is still referenced for extension whitelists but
# actual file storage now goes through ActiveStorage.
#
module Ddt::CarrierWaveBridge
  extend ActiveSupport::Concern

  class_methods do
    def mount_uploader(column, uploader_class, **opts)
      has_one_attached column

      # Store the ActiveStorage-generated method before overriding it
      original_getter = instance_method(column)

      # Provide backward-compatible accessor that returns a URL proxy
      define_method column do
        attachment = original_getter.bind(self).call

        OpenStruct.new(
          url: attachment.attached? ? Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true) : nil,
          present?: attachment.attached?,
          attached?: attachment.attached?,
          file: attachment
        )
      end

      # Provide URL method directly on the model for common pattern: model.image_url
      define_method :"#{column}_url" do
        attachment = original_getter.bind(self).call
        attachment.attached? ? Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true) : nil
      end

      # Cache the original uploader class for extension validation
      @cw_uploaders ||= {}
      @cw_uploaders[column] = uploader_class
    end
  end
end
