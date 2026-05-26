#!/usr/bin/env ruby
# MySQL to PostgreSQL Data Migration Script
#
# Migrates data from MySQL to PostgreSQL using pgloader-style approach.
# For large tables, uses batch processing with configurable chunk size.
#
# Prerequisites:
#   - PostgreSQL schema already created (run schema_converter first)
#   - Both MySQL and PostgreSQL accessible from this machine
#
# Usage:
#   ruby tools/pg_migration/migrate_data.rb [--dry-run] [--tables table1,table2] [--chunk-size 10000]

require 'mysql2'
require 'pg'
require 'optparse'

class DataMigrator
  BATCH_SIZE = 10_000

  # Tables ordered by dependency (parents first, children last)
  TABLE_ORDER = %w[
    ddt_shops
    ddt_accounts
    ddt_branches
    ddt_branch_types
    ddt_branch_groups
    ddt_branch_tags
    ddt_branch_sliders
    ddt_zones
    ddt_table_colors
    ddt_table_zones
    ddt_roles
    ddt_vip_levels
    ddt_users
    ddt_vip_infos
    ddt_wallets
    ddt_wallet_logs
    ddt_categories
    ddt_products
    ddt_variants
    ddt_combo_packages
    ddt_combo_items
    ddt_coupons
    ddt_groupons
    ddt_vouchers
    ddt_pay_methods
    ddt_orders
    ddt_line_items
    ddt_payments
    ddt_payment_logs
    ddt_shifts
    ddt_shift_items
    impressions
  ].freeze

  # Large tables that need batch processing
  LARGE_TABLES = %w[
    impressions
    ddt_line_items
    ddt_line_item_trace_points
    ddt_locations
    ddt_notification_actions
    ddt_notification_events
    ddt_notifications
    ddt_order_change_logs
    ddt_payment_logs
    ddt_print_records
    ddt_message_receptions
    ddt_message_response_items
    ddt_message_responses
  ].freeze

  attr_reader :mysql, :pg, :dry_run, :chunk_size, :stats

  def initialize(mysql_config, pg_config, options = {})
    @dry_run = options[:dry_run] || false
    @chunk_size = options[:chunk_size] || BATCH_SIZE
    @stats = { migrated: 0, skipped: 0, errors: [] }

    @mysql = Mysql2::Client.new(
      host: mysql_config[:host] || 'localhost',
      port: mysql_config[:port] || 3306,
      username: mysql_config[:username] || 'root',
      password: mysql_config[:password] || '',
      database: mysql_config[:database] || 'ddt_dev',
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

  def run(tables = nil)
    target_tables = tables || discover_tables
    target_tables = target_tables & TABLE_ORDER | (target_tables - TABLE_ORDER)

    puts "Starting data migration for #{target_tables.size} tables..."
    puts "Dry run mode - no data will be written" if dry_run

    disable_pg_triggers
    target_tables.each do |table|
      migrate_table(table)
    end
    enable_pg_triggers

    print_stats
  ensure
    mysql.close
    pg.close
  end

  private

  def discover_tables
    result = mysql.query("SHOW TABLES")
    result.map { |row| row.values.first }
  end

  def migrate_table(table)
    count = mysql.query("SELECT COUNT(*) as cnt FROM #{table}").first['cnt']
    puts "\nMigrating #{table} (#{count} rows)..."

    if dry_run
      @stats[:skipped] += 1
      return
    end

    if LARGE_TABLES.include?(table) && count > chunk_size
      migrate_in_batches(table, count)
    else
      migrate_all(table)
    end

    @stats[:migrated] += 1
  rescue => e
    puts "  ERROR: #{e.message}"
    @stats[:errors] << { table: table, error: e.message }
  end

  def migrate_all(table)
    columns = get_columns(table)
    result = mysql.query("SELECT * FROM #{table}")
    rows = result.to_a
    return if rows.empty?

    insert_batch(table, columns, rows)
    puts "  Migrated #{rows.size} rows"
  end

  def migrate_in_batches(table, total)
    columns = get_columns(table)
    offset = 0

    while offset < total
      result = mysql.query("SELECT * FROM #{table} LIMIT #{chunk_size} OFFSET #{offset}")
      rows = result.to_a
      break if rows.empty?

      insert_batch(table, columns, rows)
      offset += chunk_size
      puts "  Progress: #{[offset, total].min}/#{total}"
    end
  end

  def insert_batch(table, columns, rows)
    pg.exec("BEGIN")
    rows.each do |row|
      values = columns.map do |col|
        val = row[col]
        if val.nil?
          'NULL'
        elsif val.is_a?(String)
          "'#{pg.escape_string(val)}'"
        elsif val.is_a?(Time)
          "'#{val.strftime('%Y-%m-%d %H:%M:%S.%6N')}'"
        elsif [TrueClass, FalseClass].include?(val.class)
          val ? 'TRUE' : 'FALSE'
        else
          val.to_s
        end
      end

      sql = "INSERT INTO #{table} (#{columns.map { |c| pg.quote_ident(c) }.join(', ')}) VALUES (#{values.join(', ')})"
      pg.exec(sql)
    end
    pg.exec("COMMIT")
  rescue => e
    pg.exec("ROLLBACK")
    raise "Failed to insert batch into #{table}: #{e.message}"
  end

  def get_columns(table)
    result = mysql.query("SHOW COLUMNS FROM #{table}")
    result.map { |row| row['Field'] }
  end

  def disable_pg_triggers
    pg.exec("SET session_replication_role = 'replica';")
  end

  def enable_pg_triggers
    pg.exec("SET session_replication_role = 'origin';")
  end

  def print_stats
    puts "\n" + "=" * 50
    puts "Migration Complete"
    puts "  Migrated: #{@stats[:migrated]} tables"
    puts "  Skipped (dry-run): #{@stats[:skipped]} tables"
    puts "  Errors: #{@stats[:errors].size}"
    @stats[:errors].each do |err|
      puts "    #{err[:table]}: #{err[:error]}"
    end
  end
end

if __FILE__ == $0
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: ruby migrate_data.rb [options]"
    opts.on("--dry-run", "Don't write data, just report") { options[:dry_run] = true }
    opts.on("--tables TABLES", "Comma-separated table list") { |t| options[:tables] = t.split(',') }
    opts.on("--chunk-size N", Integer, "Batch size for large tables") { |n| options[:chunk_size] = n }
  end.parse!

  migrator = DataMigrator.new(
    { host: ENV['MYSQL_HOST'] || 'localhost',
      port: (ENV['MYSQL_PORT'] || 3306).to_i,
      username: ENV['MYSQL_USER'] || 'root',
      password: ENV['MYSQL_PASSWORD'] || 'root',
      database: ENV['MYSQL_DATABASE'] || 'ddt_dev' },
    { host: ENV['PG_HOST'] || 'localhost',
      port: (ENV['PG_PORT'] || 5432).to_i,
      username: ENV['PG_USER'] || 'postgres',
      password: ENV['PG_PASSWORD'] || 'postgres',
      database: ENV['PG_DATABASE'] || 'ddt_dev' },
    options
  )

  migrator.run(options[:tables])
end
