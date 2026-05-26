#!/usr/bin/env ruby
# Data Validation Script
# Compares row counts and checksums between MySQL and PostgreSQL
# to verify data integrity after migration.
#
# Usage: ruby tools/pg_migration/validate_data.rb

require 'mysql2'
require 'pg'

class DataValidator
  def initialize(mysql, pg)
    @mysql = mysql
    @pg = pg
  end

  def run
    puts "=" * 60
    puts "Data Validation: MySQL vs PostgreSQL"
    puts "=" * 60

    mysql_tables = get_mysql_tables
    pg_tables = get_pg_tables

    common = mysql_tables & pg_tables
    mysql_only = mysql_tables - pg_tables
    pg_only = pg_tables - mysql_tables

    puts "\nTable counts: MySQL=#{mysql_tables.size}, PostgreSQL=#{pg_tables.size}"
    puts "Common tables: #{common.size}"

    if mysql_only.any?
      puts "\nTables only in MySQL: #{mysql_only.join(', ')}"
    end
    if pg_only.any?
      puts "Tables only in PostgreSQL: #{pg_only.join(', ')}"
    end

    puts "\nRow count comparison:"
    puts "%-45s %12s %12s %s" % ["Table", "MySQL", "PostgreSQL", "Status"]
    puts "-" * 80

    errors = []
    common.sort.each do |table|
      mysql_count = get_mysql_count(table)
      pg_count = get_pg_count(table)
      status = mysql_count == pg_count ? "OK" : "MISMATCH"
      puts "%-45s %12d %12d %s" % [table, mysql_count, pg_count, status]
      errors << table if mysql_count != pg_count
    end

    puts "\n" + "=" * 60
    if errors.empty?
      puts "All tables validated successfully!"
    else
      puts "WARNING: #{errors.size} tables have count mismatches:"
      errors.each { |t| puts "  - #{t}" }
    end
  ensure
    @mysql.close
    @pg.close
  end

  private

  def get_mysql_tables
    @mysql.query("SHOW TABLES").map { |r| r.values.first }
  end

  def get_pg_tables
    @pg.exec("SELECT tablename FROM pg_tables WHERE schemaname = 'public'").map { |r| r['tablename'] }
  end

  def get_mysql_count(table)
    @mysql.query("SELECT COUNT(*) as cnt FROM `#{table}`").first['cnt']
  end

  def get_pg_count(table)
    @pg.exec("SELECT COUNT(*) as cnt FROM #{PG::Connection.quote_ident(table)}").first['cnt'].to_i
  end
end

if __FILE__ == $0
  mysql = Mysql2::Client.new(
    host: ENV['MYSQL_HOST'] || 'localhost',
    username: ENV['MYSQL_USER'] || 'root',
    password: ENV['MYSQL_PASSWORD'] || 'root',
    database: ENV['MYSQL_DATABASE'] || 'ddt_dev',
    encoding: 'utf8mb4'
  )

  pg = PG.connect(
    host: ENV['PG_HOST'] || 'localhost',
    port: (ENV['PG_PORT'] || 5432).to_i,
    dbname: ENV['PG_DATABASE'] || 'ddt_dev',
    user: ENV['PG_USER'] || 'postgres',
    password: ENV['PG_PASSWORD'] || 'postgres'
  )

  DataValidator.new(mysql, pg).run
end
