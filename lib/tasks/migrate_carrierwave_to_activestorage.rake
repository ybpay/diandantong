# Data migration: move files from CarrierWave (disk + Aliyun OSS) to ActiveStorage.
#
# Run with: bin/rails carrierwave:to_activestorage
#
# This task reads existing CarrierWave file paths from model database columns
# and creates ActiveStorage attachments pointing to the same files.
#
# Storage backends:
#   - Local disk: public/ddb_uploads/ (default CarrierWave file storage)
#   - Aliyun OSS: files uploaded via `storage :aliyun` uploaders
#
# For Aliyun OSS migration, configure credentials via:
#   - Environment: ALIYUN_OSS_ENDPOINT, ALIYUN_OSS_BUCKET, ALIYUN_OSS_ACCESS_KEY_ID, ALIYUN_OSS_ACCESS_KEY_SECRET
#   - Or Rails.credentials.dig(:aliyun_oss, :endpoint), etc.
#
namespace :carrierwave do
  desc "Migrate existing CarrierWave files to ActiveStorage"
  task to_activestorage: :environment do
    # Each entry: [ModelClass, column, variants: {}, storage: :disk|:aliyun|:mixed, oss_prefix: nil]
    #
    # storage :aliyun means the file is on Aliyun OSS with the given oss_prefix path.
    # oss_prefix can be a String (static prefix) or a Proc receiving (record, filename) returning
    # the full OSS object key.
    attachments = [
      # --- Disk storage (public/ddb_uploads/) ---
      [Ddt::Shop, :image],
      [Ddt::Shop, :rect_image],
      [Ddt::Shop, :reservation_img],
      [Ddt::Shop, :order_in_seat_img],
      [Ddt::Shop, :delivery_img],
      [Ddt::Shop, :queue_img],
      [Ddt::Shop, :pay_online_img],
      [Ddt::Branch, :image],
      [Ddt::Branch, :rect_image],
      [Ddt::BranchType, :image],
      [Ddt::BranchType, :reservation_img],
      [Ddt::BranchType, :order_in_seat_img],
      [Ddt::BranchType, :delivery_img],
      [Ddt::BranchType, :fastfood_img],
      [Ddt::BranchType, :queue_img],
      [Ddt::BranchType, :pay_online_img],
      [Ddt::BranchSlider, :img],
      [Ddt::Agent, :logo],
      [Ddt::Agent, :rect_logo],
      [Ddt::VipInfo, :avatar],
      [Ddt::Article, :image],
      [Ddt::CustomWeixinInfo, :background_image],
      [Ddt::HomeUsableLink, :image],
      [Ddt::HomeHotLink, :image],
      [Ddt::CouponPhoto, :image],
      [Ddt::Promotion, :image],
      [Ddt::QrCodeScene, :url],
      [Ddt::VerifyVipInfoQrCodeScene, :url],
      [Ddt::PayQrCodeScene, :url],
      [Ddt::ComboImage, :attachment],
      [Ddt::VariantImage, :attachment],
      [Ddt::QueueSetting, :queue_qr_code],
      [Ddt::OnePage, :image],

      # --- Aliyun OSS storage ---
      [Ddt::DFile, :file_path,       { storage: :aliyun, oss_prefix: ->(r, f) { "uploads/d_file/#{r.id}/#{f}" } }],
      [Ddt::UploadedFile, :file,     { storage: :aliyun, oss_prefix: ->(r, f) { "uploads/tempfile/#{r.id}/#{f}" } }],
      [Ddt::StatisticsCache, :result, { storage: :aliyun, oss_prefix: ->(r, f) { "uploads/statistics-cache/#{r.id}/#{f}" } }],
      [Ddt::StatisticsCache, :csv,   { storage: :aliyun, oss_prefix: ->(r, f) { "uploads/statistics-cache/#{r.id}/#{f}" } }],
      [Ddt::StatisticsCache, :xls,   { storage: :aliyun, oss_prefix: ->(r, f) { "uploads/statistics-cache/#{r.id}/#{f}" } }],
      [Ddt::WechatAccount, :server_auth_file, { storage: :aliyun, oss_prefix: ->(r, f) { "uploads/wechat_account_server_auth_files/#{f}" } }],
      [Ddt::Shop, :last_import_vip_info_error, { storage: :aliyun, oss_prefix: ->(r, f) { "uploads/import_vip_info_error/#{r.id}/#{f}" } }],
    ]

    migrated = 0
    skipped  = 0
    errors   = 0

    oss_client = build_oss_client

    attachments.each do |(klass, column, opts)|
      opts ||= {}
      storage    = opts[:storage] || :disk
      oss_prefix = opts[:oss_prefix]
      klass_name = klass.name
      puts "\n== Migrating #{klass_name}##{column} (#{storage}) =="

      klass.find_each(batch_size: 100) do |record|
        # Skip if already attached via ActiveStorage
        if record.public_send(column).attached?
          skipped += 1
          next
        end

        # Read the CarrierWave file path from the DB column
        filename = record.read_attribute(column)
        if filename.blank?
          skipped += 1
          next
        end

        io = nil

        if storage == :disk
          io = fetch_from_disk(klass_name, column, record.id, filename)
        end

        # Fallback: try Aliyun OSS if disk not found (or storage was :aliyun)
        if io.nil? && (storage == :aliyun || storage == :disk)
          if oss_client && storage == :aliyun
            oss_key = oss_prefix ? oss_prefix.call(record, filename) : default_oss_key(klass_name, column, record.id, filename)
            io = fetch_from_oss(oss_client, oss_key, filename)
          elsif oss_client && storage == :disk
            # Try OSS as fallback for disk-stored files that might have been migrated
            oss_key = default_oss_key(klass_name, column, record.id, filename)
            io = fetch_from_oss(oss_client, oss_key, filename)
          end
        end

        if io.nil?
          skipped += 1
          next
        end

        begin
          content_type = Marcel::MimeType.for(io, name: filename)
          io.rewind
          record.public_send(column).attach(
            io: io,
            filename: filename,
            content_type: content_type
          )
          migrated += 1
          putc "."
        rescue => e
          errors += 1
          puts "\n  ERROR #{klass_name}##{record.id} #{column}: #{e.message}"
        ensure
          io.close if io
        end
      end
    end

    puts "\n\n== Migration complete =="
    puts "Migrated: #{migrated}"
    puts "Skipped:  #{skipped}"
    puts "Errors:   #{errors}"
  end

  # Try local disk paths used by CarrierWave file storage.
  def fetch_from_disk(klass_name, column, record_id, filename)
    relative_path = "ddb_uploads/#{klass_name.underscore}/#{column}/#{record_id}/#{filename}"
    file_path = Rails.root.join("public", relative_path)
    return File.open(file_path, "rb") if File.exist?(file_path)

    alt_path = Rails.root.join(relative_path)
    return File.open(alt_path, "rb") if File.exist?(alt_path)

    nil
  end

  # Build an OSS download client from credentials.
  # Returns nil if credentials are not configured (non-OSS migration proceeds normally).
  def build_oss_client
    creds = {
      endpoint:        ENV["ALIYUN_OSS_ENDPOINT"]        || Rails.application.credentials.dig(:aliyun_oss, :endpoint),
      bucket:          ENV["ALIYUN_OSS_BUCKET"]          || Rails.application.credentials.dig(:aliyun_oss, :bucket),
      access_key_id:   ENV["ALIYUN_OSS_ACCESS_KEY_ID"]   || Rails.application.credentials.dig(:aliyun_oss, :access_key_id),
      access_key_secret: ENV["ALIYUN_OSS_ACCESS_KEY_SECRET"] || Rails.application.credentials.dig(:aliyun_oss, :access_key_secret),
    }

    if creds.values_at(:endpoint, :bucket, :access_key_id, :access_key_secret).all?(&:present?)
      require "aliyun/oss" rescue nil
      if defined?(Aliyun::OSS::Client)
        Aliyun::OSS::Client.new(
          endpoint: creds[:endpoint],
          access_key_id: creds[:access_key_id],
          access_key_secret: creds[:access_key_secret],
        ).get_bucket(creds[:bucket])
      else
        # Fallback: use direct HTTP download with public read or signed URL
        OpenStruct.new(creds) # minimal client for HTTP-based download
      end
    else
      puts "  [INFO] Aliyun OSS credentials not configured; skipping OSS migration."
      nil
    end
  end

  # Download a file from Aliyun OSS.
  def fetch_from_oss(client, oss_key, filename)
    return nil unless client

    begin
      if defined?(Aliyun::OSS::Client) && client.is_a?(Aliyun::OSS::Bucket)
        # SDK-based download
        content = client.get_object(oss_key)
        io = StringIO.new(content)
        io
      else
        # HTTP-based fallback: try public URL first, then signed URL
        endpoint = client.respond_to?(:endpoint) ? client.endpoint : nil
        bucket   = client.respond_to?(:bucket) ? client.bucket : nil
        return nil unless endpoint && bucket

        url = "#{endpoint}/#{bucket}/#{oss_key}"
        require "open-uri"
        io = URI.open(url, "rb", read_timeout: 30, open_timeout: 10)
        io
      end
    rescue => e
      puts "\n  [OSS] #{oss_key}: #{e.message}"
      nil
    end
  end

  # Default OSS key pattern matching CarrierWave's store_dir for non-aliyun uploaders.
  def default_oss_key(klass_name, column, record_id, filename)
    "ddb_uploads/#{klass_name.underscore}/#{column}/#{record_id}/#{filename}"
  end
end
