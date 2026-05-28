# Replaces CarrierWaveBridge with native ActiveStorage support.
#
# Provides backward-compatible URL methods including variant support
# so existing code like `shop.image.thumb.url` continues to work.
#
# Usage:
#   include Ddt::Attachable
#   attachable_one :image, variants: { thumb: [140, 140], medium: [400, 400] }
#   attachable_one :logo, variants: { thumb: { size: [360, 200], mode: :fit } }
#   attachable_one :document  # no variants
#
# Variant format: [width, height] (defaults to resize_to_fill) or
#   { size: [width, height], mode: :fit | :fill } (explicit resize mode)
#
module Ddt::Attachable
  extend ActiveSupport::Concern

  # Lightweight proxy that mimics CarrierWave uploader response.
  # Supports .url, .present?, .attached?, and variant accessors.
  class AttachmentProxy
    def initialize(record, column, variants, raw_attachment_fn)
      @record     = record
      @column     = column
      @variants   = variants
      @raw_fn     = raw_attachment_fn
    end

    def attached?
      @raw_fn.call.attached?
    end
    alias_method :present?, :attached?

    def url
      return nil unless attached?
      Rails.application.routes.url_helpers.rails_blob_path(@raw_fn.call, only_path: true)
    end

    def file
      @raw_fn.call
    end

    def method_missing(name, *args)
      if @variants.key?(name)
        VariantProxy.new(@raw_fn, @variants[name])
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @variants.key?(name) || super
    end
  end

  # Proxy for a specific variant size.
  # Supports both resize_to_fill (crop) and resize_to_fit (preserve ratio).
  class VariantProxy
    def initialize(raw_attachment_fn, variant_config)
      @raw_fn = raw_attachment_fn
      @dimensions, @resize_mode = self.class.parse_variant_config(variant_config)
    end

    def attached?
      attachment = @raw_fn.call
      attachment.attached?
    end
    alias_method :present?, :attached?

    def url
      attachment = @raw_fn.call
      return nil unless attachment.attached?
      return Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true) unless attachment.variable?

      variant = attachment.variant(@resize_mode => @dimensions)
      Rails.application.routes.url_helpers.rails_representation_path(variant, only_path: true)
    end

    def self.parse_variant_config(config)
      case config
      when Array
        [config, :resize_to_fill]
      when Hash
        [config[:size], config[:mode] || :resize_to_fill]
      else
        [config, :resize_to_fill]
      end
    end
  end

  included do
    before_save :purge_marked_attachments
  end

  class_methods do
    def attachable_one(column, variants: {})
      has_one_attached column

      @attachable_variants ||= {}
      @attachable_variants[column] = variants

      # Capture the original ActiveStorage getter before overriding
      original_getter = instance_method(column)

      raw_fn = ->(record) { original_getter.bind(record).call }

      define_method column do
        AttachmentProxy.new(self, column, self.class.attachable_variants_for(column), raw_fn)
      end

      define_method :"#{column}_url" do
        attachment = raw_fn.call(self)
        return nil unless attachment.attached?
        Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true)
      end

      define_method :"#{column}_variant" do |variant_name|
        variants_config = self.class.attachable_variants_for(column)
        config = variants_config[variant_name]
        return nil unless config

        dimensions, resize_mode = VariantProxy.parse_variant_config(config)

        attachment = raw_fn.call(self)
        return nil unless attachment.attached?
        return Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true) unless attachment.variable?

        variant = attachment.variant(resize_mode => dimensions)
        Rails.application.routes.url_helpers.rails_representation_path(variant, only_path: true)
      end

      define_method :"#{column}?" do
        raw_fn.call(self).attached?
      end

      attr_accessor :"remove_#{column}"
    end

    def attachable_variants_for(column)
      @attachable_variants&.dig(column) || {}
    end

    def attachable_columns
      @attachable_variants&.keys || []
    end
  end

  private

  def purge_marked_attachments
    self.class.attachable_columns.each do |column|
      remove_flag = public_send("remove_#{column}")
      if remove_flag.present? && remove_flag != "0" && remove_flag != false
        attachment = method(column).super_method.call(self)
        attachment.purge if attachment.attached?
      end
    end
  end
end
