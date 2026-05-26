#!/usr/bin/env ruby
# Migrate impression data from the separate MySQL impression database
# into the main PostgreSQL database.
#
# Usage:
#   ruby tools/pg_migration/migrate_impressions.rb [--dry-run]
#
# Environment variables:
#   MYSQL_IMPRESSION_HOST (default: localhost)
#   MYSQL_IMPRESSION_PORT (default: 3306)
#   MYSQL_IMPRESSION_USER (default: root)
#   MYSQL_IMPRESSION_PASSWORD (default: root)
#   MYSQL_IMPRESSION_DATABASE (default: ddb_impression_dev)
#   PG_HOST, PG_PORT, PG_USER, PG_PASSWORD, PG_DATABASE

require 'mysql2'
require 'pg'
require 'optparse'

class ImpressionMigrator
  attr_reader :mysql, :pg, :dry_run

  def initialize(mysql_config, pg_config, dry_run: false)
    @dry_run = dry_run

    @mysql = Mysql2::Client.new(
      host: mysql_config[:host] || 'localhost',
      port: mysql_config[:port] || 3306,
      username: mysql_config[:username] || 'root',
      password: mysql_config[:password] || 'root',
      database: mysql_config[:database] || 'ddb_impression_dev',
      encoding: 'utf8mb4'
    )

    @pg = PG.connect(
      host: pg_config[:host] || 'localhost',
      port: pg_config[:port] || 5432,
      dbname: pg_config[:database] || 'ddt_dev',
      user: pg_config[:username] || 'postgres',
      password: pg_config[:password] || 'postgres'
    )
  end

  def run
    count = mysql.query("SELECT COUNT(*) as cnt FROM impressions").first['cnt']
    puts "Migrating #{count} impressions from separate MySQL database..."
    puts "Dry run mode" if dry_run

    return if dry_run

    batch_size = 50_000
    offset = 0

    while offset < count
      rows = mysql.query("SELECT * FROM impressions ORDER BY id LIMIT #{batch_size} OFFSET #{offset}").to_a
      break if rows.empty?

      pg.exec("BEGIN")
      rows.each do |row|
        cols = %w[id impressionable_type impressionable_id user_id controller_name action_name view_name request_hash session_hash ip_address referrer message created_at updated_at]
        vals = cols.map { |c| pg_value(row[c]) }
        pg.exec("INSERT INTO impressions (#{cols.join(', ')}) VALUES (#{vals.join(', ')}) ON CONFLICT (id) DO NOTHING")
      end
      pg.exec("COMMIT")

      offset += batch_size
      puts "  Progress: #{[offset, count].min}/#{count}"
    end

    # Reset the PostgreSQL sequence to the max id
    pg.exec("SELECT setval('impressions_id_seq', (SELECT COALESCE(MAX(id), 0) FROM impressions))")
    puts "Done. Updated sequence to current max id."
  rescue => e
    pg.exec("ROLLBACK") rescue nil
    puts "ERROR: #{e.message}"
    raise
  ensure
    mysql.close
    pg.close
  end

  private

  def pg_value(val)
    return 'NULL' if val.nil?
    return "'#{pg.escape_string(val.to_s)}'" if val.is_a?(String)
    return "'#{val.strftime('%Y-%m-%d %H:%M:%S.%6N')}'" if val.is_a?(Time)
    val.to_s
  end
end

if __FILE__ == $0
  options = {}
  OptionParser.new { |opts| opts.on("--dry-run") { options[:dry_run] = true } }.parse!

  ImpressionMigrator.new(
    { host: ENV['MYSQL_IMPRESSION_HOST'] || 'localhost',
      port: (ENV['MYSQL_IMPRESSION_PORT'] || 3306).to_i,
      username: ENV['MYSQL_IMPRESSION_USER'] || 'root',
      password: ENV['MYSQL_IMPRESSION_PASSWORD'] || 'root',
      database: ENV['MYSQL_IMPRESSION_DATABASE'] || 'ddb_impression_dev' },
    { host: ENV['PG_HOST'] || 'localhost',
      port: (ENV['PG_PORT'] || 5432).to_i,
      username: ENV['PG_USER'] || 'postgres',
      password: ENV['PG_PASSWORD'] || 'postgres',
      database: ENV['PG_DATABASE'] || 'ddt_dev' },
    **options
  ).run
end
