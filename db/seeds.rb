# encoding:utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
role = Ddt::Role.admin_role
account = Ddt::Account.new(:login_id=> 'admin', :password=>"adminadmin", :phone=>"13800000000", :email=>"admin@diandantong.com")
account.roles << role
account.save(validate: false)