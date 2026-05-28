#!/usr/bin/env ruby
# frozen_string_literal: true

# E2E test data seeder.
# Run: rails runner e2e/fixtures/seed.rb

# Create a test shop with boss account
shop = Ddt::Shop.find_or_create_by!(slug: "demo-shop") do |s|
  s.name = "Demo Restaurant"
  s.phone = "13800138000"
  s.address = "123 Test Street"
  s.state = "active"
end

# Create boss account
boss_role = Ddt::Role.find_or_create_by!(name: "Boss") do |r|
  r.permissions = %w[read_products write_products read_orders write_orders manage_roles manage_staff]
end

boss_account = Ddt::Account.find_or_create_by!(login_id: "demo-shop:boss") do |a|
  a.email = "boss@demo-shop.test"
  a.password = "password123"
  a.password_confirmation = "password123"
  a.name = "Boss User"
  a.phone = "13800138001"
  a.shop = shop
  a.accept_term = true
end
boss_account.roles << boss_role unless boss_account.roles.include?(boss_role)

# Create admin account
admin_role = Ddt::Role.find_or_create_by!(name: "Admin") do |r|
  r.permissions = %w[read_products write_products read_orders write_orders manage_staff]
end

admin_account = Ddt::Account.find_or_create_by!(login_id: "demo-shop:admin") do |a|
  a.email = "admin@demo-shop.test"
  a.password = "password123"
  a.password_confirmation = "password123"
  a.name = "Admin User"
  a.phone = "13800138002"
  a.shop = shop
  a.accept_term = true
end
admin_account.roles << admin_role unless admin_account.roles.include?(admin_role)

# Create staff account (limited permissions)
staff_role = Ddt::Role.find_or_create_by!(name: "Staff") do |r|
  r.permissions = %w[read_products read_orders]
end

staff_account = Ddt::Account.find_or_create_by!(login_id: "demo-shop:staff") do |a|
  a.email = "staff@demo-shop.test"
  a.password = "password123"
  a.password_confirmation = "password123"
  a.name = "Staff User"
  a.phone = "13800138003"
  a.shop = shop
  a.accept_term = true
end
staff_account.roles << staff_role unless staff_account.roles.include?(staff_role)

# Create main branch
branch = Ddt::Branch.find_or_create_by!(shop: shop, name: "Main Branch") do |b|
  b.address = "123 Test Street"
  b.phone = "13800138000"
  b.latitude = 31.2304
  b.longitude = 121.4737
  b.state = "active"
end

# Create test category
category = Ddt::Category.find_or_create_by!(branch: branch, name: "E2E Test Category") do |c|
  c.position = 999
end

# Create test products
5.times do |i|
  Ddt::Product.find_or_create_by!(branch: branch, name: "E2E Test Product #{i + 1}") do |p|
    p.price = (10 + i * 5).to_f
    p.unit = "份"
    p.description = "E2E test product #{i + 1}"
    p.category = category
    p.state = "on_shelf"
  end
end

# Create test agent
agent_account = Ddt::Account.find_or_create_by!(login_id: "test-agent") do |a|
  a.email = "agent@test.test"
  a.password = "agent123"
  a.password_confirmation = "agent123"
  a.name = "Test Agent"
  a.phone = "13900139000"
  a.accept_term = true
end

puts "E2E seed data created successfully!"
puts "  Shop: #{shop.name} (#{shop.slug})"
puts "  Branch: #{branch.name} (ID: #{branch.id})"
puts "  Boss: demo-shop:boss / password123"
puts "  Admin: demo-shop:admin / password123"
puts "  Staff: demo-shop:staff / password123"
puts "  Agent: test-agent / agent123"
puts "  Products: 5 test products in '#{category.name}'"
