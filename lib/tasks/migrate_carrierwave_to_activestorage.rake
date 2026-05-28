# Data migration: move files from CarrierWave disk storage to ActiveStorage.
#
# Run with: bin/rails carrierwave:to_activestorage
#
# This task reads existing CarrierWave file paths from model database columns
# and creates ActiveStorage attachments pointing to the same files.
# After running, files stored in public/ddb_uploads/ are registered
# with ActiveStorage's blob system.
#
namespace :carrierwave do
  desc "Migrate existing CarrierWave files to ActiveStorage"
  task to_activestorage: :environment do
    # Mapping: [ModelClass, column, variants: {}]
    attachments = [
      [Ddt::Shop, :image],
      [Ddt::Shop, :rect_image],
      [Ddt::Shop, :vip_logo],
      [Ddt::Shop, :reservation_img],
      [Ddt::Shop, :order_in_seat_img],
      [Ddt::Shop, :delivery_img],
      [Ddt::Shop, :queue_img],
      [Ddt::Shop, :pay_online_img],
      [Ddt::Shop, :last_import_vip_info_error],
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
      [Ddt::DFile, :file_path],
      [Ddt::VipInfo, :avatar],
      [Ddt::Article, :image],
      [Ddt::OnePage, :image],
      [Ddt::WechatAccount, :server_auth_file],
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
      [Ddt::UploadedFile, :file],
      [Ddt::StatisticsCache, :result],
      [Ddt::StatisticsCache, :csv],
      [Ddt::StatisticsCache, :xls],
    ]

    migrated = 0
    skipped = 0
    errors  = 0

    attachments.each do |(klass, column)|
      klass_name = klass.name
      puts "\n== Migrating #{klass_name}##{column} =="

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

        # CarrierWave stored files under public/ddb_uploads/
        relative_path = "ddb_uploads/#{klass_name.underscore}/#{column}/#{record.id}/#{filename}"
        file_path = Rails.root.join("public", relative_path)

        unless File.exist?(file_path)
          # Try alternate location without public/
          alt_path = Rails.root.join(relative_path)
          if File.exist?(alt_path)
            file_path = alt_path
          else
            skipped += 1
            next
          end
        end

        begin
          content_type = Marcel::MimeType.for(File.open(file_path, "rb"), name: filename)
          record.public_send(column).attach(
            io: File.open(file_path, "rb"),
            filename: filename,
            content_type: content_type
          )
          migrated += 1
          putc "."
        rescue => e
          errors += 1
          puts "\n  ERROR #{klass_name}##{record.id} #{column}: #{e.message}"
        end
      end
    end

    puts "\n\n== Migration complete =="
    puts "Migrated: #{migrated}"
    puts "Skipped:  #{skipped}"
    puts "Errors:   #{errors}"
  end
end
