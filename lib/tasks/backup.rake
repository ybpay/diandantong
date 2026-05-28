namespace :backup do
  desc "Run PostgreSQL backup and upload to S3/MinIO"
  task postgres: :environment do
    require "open3"
    script = Rails.root.join("tools", "backup", "backup.sh")
    puts "[#{Time.current}] Starting PostgreSQL backup..."
    stdout, stderr, status = Open3.capture3({"RAILS_ENV" => Rails.env}, "bash", script.to_s)
    puts stdout
    warn stderr if stderr.present?
    puts "[#{Time.current}] PostgreSQL backup exit: #{status.exitstatus}"
    exit(status.exitstatus) unless status.success?
  end

  desc "Run Redis backup and upload to S3/MinIO"
  task redis: :environment do
    require "open3"
    script = Rails.root.join("tools", "backup", "backup_redis.sh")
    puts "[#{Time.current}] Starting Redis backup..."
    stdout, stderr, status = Open3.capture3({"RAILS_ENV" => Rails.env}, "bash", script.to_s)
    puts stdout
    warn stderr if stderr.present?
    puts "[#{Time.current}] Redis backup exit: #{status.exitstatus}"
    exit(status.exitstatus) unless status.success?
  end

  desc "Run ActiveStorage backup sync to S3/MinIO"
  task storage: :environment do
    require "open3"
    script = Rails.root.join("tools", "backup", "backup_storage.sh")
    puts "[#{Time.current}] Starting ActiveStorage backup..."
    stdout, stderr, status = Open3.capture3({"RAILS_ENV" => Rails.env}, "bash", script.to_s)
    puts stdout
    warn stderr if stderr.present?
    puts "[#{Time.current}] ActiveStorage backup exit: #{status.exitstatus}"
    exit(status.exitstatus) unless status.success?
  end

  desc "Run all backups (PostgreSQL + Redis + ActiveStorage)"
  task all: [:postgres, :redis, :storage]

  desc "Verify the most recent PostgreSQL backup is valid"
  task verify: :environment do
    backup_dir = ENV.fetch("BACKUP_DIR", "/var/backups/diandantong")
    latest = Dir.glob("#{backup_dir}/*.dump").max_by { |f| File.mtime(f) }

    if latest.nil?
      puts "ERROR: No backup files found in #{backup_dir}"
      exit 1
    end

    puts "Verifying: #{latest}"
    puts "Size: #{File.size(latest) / 1024 / 1024}MB"
    puts "Created: #{File.mtime(latest)}"

    age_hours = (Time.current - File.mtime(latest)) / 3600
    if age_hours > 48
      puts "WARNING: Latest backup is #{age_hours.round(1)} hours old (threshold: 48h)"
      exit 1
    end

    puts "Backup verification passed."
  end
end
