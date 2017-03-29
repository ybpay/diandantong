class AddOptionsToDiscountPlan < ActiveRecord::Migration
  def change
    add_column :ddt_discount_plans, :start_at, :datetime
    add_column :ddt_discount_plans, :end_at, :datetime
    add_column :ddt_discount_plans, :enable_on_monday, :boolean, default: true
    add_column :ddt_discount_plans, :enable_on_tuesday, :boolean, default: true
    add_column :ddt_discount_plans, :enable_on_wednesday, :boolean, default: true
    add_column :ddt_discount_plans, :enable_on_thursday, :boolean, default: true
    add_column :ddt_discount_plans, :enable_on_friday, :boolean, default: true
    add_column :ddt_discount_plans, :enable_on_saturday, :boolean, default: true
    add_column :ddt_discount_plans, :enable_on_sunday, :boolean, default: true
  end
end
