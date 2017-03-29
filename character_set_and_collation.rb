#!/usr/bin/env ruby
 
# Put this file in the root of your Rails project,
# then run it to output the SQL needed to change all
# your tables and columns to the same character set 
# and collation.
#
# > ruby character_set_and_collation.rb
 
DATABASE      = 'ddt_dev'
CHARACTER_SET = 'utf8mb4'
COLLATION     = 'utf8mb4_unicode_ci'
 
schema = File.open('db/schema.rb', 'r').read
rows = schema.split("\n")
 
table_name = nil
rows.each do |row|
  if row =~ /create_table/
    table_name = row.match(/create_table "(.+)"/)[1]
    puts "ALTER TABLE `#{DATABASE}`.`#{table_name}` CONVERT TO CHARACTER SET #{CHARACTER_SET} COLLATE #{COLLATION};"
  # elsif row =~ /t\.string/
  #   field_name = row.match(/"(.+)"/)[1]
  #   puts "ALTER TABLE `#{DATABASE}`.`#{table_name}` CHANGE COLUMN `#{field_name}` `#{field_name}` CHARACTER SET #{CHARACTER_SET} COLLATE #{COLLATION};"
  # elsif row =~ /t\.text/
  #   field_name = row.match(/"(.+)"/)[1]
  #   puts "ALTER TABLE `#{DATABASE}`.`#{table_name}` CHANGE COLUMN `#{field_name}` `#{field_name}` CHARACTER SET #{CHARACTER_SET} COLLATE #{COLLATION};"
  end
end
