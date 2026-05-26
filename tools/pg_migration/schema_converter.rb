#!/usr/bin/env ruby
# MySQL to PostgreSQL Schema Converter
#
# Converts a MySQL schema dump to PostgreSQL-compatible DDL.
# Usage:
#   1. Export MySQL schema: mysqldump --no-data -u root -p ddt_dev > mysql_schema.sql
#   2. Run this script: ruby tools/pg_migration/schema_converter.rb mysql_schema.sql > pg_schema.sql
#   3. Import to PostgreSQL: psql -U postgres -d ddt_dev -f pg_schema.sql
#
# This handles:
#   - Data type mapping (TINYINT→BOOLEAN/SMALLINT, DATETIME→TIMESTAMPTZ, etc.)
#   - Index syntax conversion
#   - AUTO_INCREMENT→SERIAL
#   - Character set removal
#   - Engine removal
#   - Backtick removal

require 'strscan'

class MysqlToPgConverter
  def initialize(input)
    @input = input
  end

  def convert
    output = []
    @input.each_line do |line|
      converted = convert_line(line)
      output << converted if converted
    end
    output.join("\n")
  end

  private

  def convert_line(line)
    stripped = line.strip

    # Skip MySQL-specific lines
    return nil if stripped.start_with?('/*!')
    return nil if stripped =~ /^SET\s+(character_set|names|collation|time_zone|sql_mode)/i
    return nil if stripped =~ /^LOCK TABLES/i
    return nil if stripped =~ /^UNLOCK TABLES/i
    return nil if stripped =~ /^ENGINE\s*=/i
    return nil if stripped.start_with?('--')

    result = line.dup

    # Remove backticks
    result.gsub!('`', '')

    # AUTO_INCREMENT removal (in table definitions)
    result.gsub!(/\s*AUTO_INCREMENT\s*=\s*\d+/i, '')

    # Character set and collation removal
    result.gsub!(/\s*CHARACTER SET \w+/i, '')
    result.gsub!(/\s*COLLATE \w+/i, '')
    result.gsub!(/\s*charset\s*=\s*\w+/i, '')
    result.gsub!(/\s*DEFAULT CHARSET=\w+/i, '')
    result.gsub!(/\s*COLLATE=\w+/i, '')

    # ENGINE removal
    result.gsub!(/\s*ENGINE\s*=\s*\w+/i, '')
    result.gsub!(/\s*ROW_FORMAT\s*=\s*\w+/i, '')

    # Data type conversions
    result.gsub!(/tinyint\(1\)/i, 'BOOLEAN')
    result.gsub!(/tinyint\((?!1\))\d+\)/i, 'SMALLINT')
    result.gsub!(/tinyint/i, 'SMALLINT')
    result.gsub!(/smallint\(\d+\)/i, 'SMALLINT')
    result.gsub!(/mediumint\(\d+\)/i, 'INTEGER')
    result.gsub!(/int\(\d+\)/i, 'INTEGER')
    result.gsub!(/bigint\(\d+\)/i, 'BIGINT')
    result.gsub!(/mediumtext/i, 'TEXT')
    result.gsub!(/longtext/i, 'TEXT')
    result.gsub!(/datetime/i, 'TIMESTAMP WITH TIME ZONE')
    result.gsub!(/double/i, 'DOUBLE PRECISION')
    result.gsub!(/float/i, 'REAL')
    result.gsub!(/enum\([^)]+\)/i) { |m| "VARCHAR(50)" }
    result.gsub!(/unsigned/i, '')

    # AUTO_INCREMENT in column definitions → SERIAL handling
    result.gsub!(/integer\s+NOT NULL\s+AUTO_INCREMENT/i, 'SERIAL PRIMARY KEY')

    # VARCHAR length adjustments (MySQL utf8mb4 uses 4 bytes per char, PG uses variable)
    # Keep varchar lengths as-is since they're still useful constraints

    # Index conversions
    result.gsub!(/KEY\s+(\w+)\s*\(([^)]+)\)/i) { "INDEX #{$1} (#{$2})" }
    result.gsub!(/UNIQUE KEY\s+(\w+)\s*\(([^)]+)\)/i) { "UNIQUE INDEX #{$1} (#{$2})" }
    result.gsub!(/PRIMARY KEY\s*\(([^)]+)\)/i) { "PRIMARY KEY (#{$1})" }

    # Remove USING BTREE
    result.gsub!(/\s*USING BTREE/i, '')

    # Index length specifiers (MySQL-specific)
    result.gsub!(/\(\d+\)/, '')

    # Convert ON DELETE/ON UPDATE
    result.gsub!(/ON DELETE RESTRICT/i, 'ON DELETE RESTRICT')

    # IF EXISTS for DROP TABLE
    result.gsub!(/DROP TABLE IF EXISTS/, 'DROP TABLE IF EXISTS')

    # Row format
    result.gsub!(/ROW_FORMAT\s*=\s*\w+/i, '')

    # Comment handling
    result.gsub!(/COMMENT\s+'[^']*'/i, '')

    # Clean up multiple spaces
    result.gsub!(/\s{2,}/, ' ')

    result
  end
end

if __FILE__ == $0
  input = ARGV[0] ? File.read(ARGV[0]) : $stdin.read
  puts MysqlToPgConverter.new(input).convert
end
