FactoryGirl.define do
  factory :table_zone, class: Ddt::TableZone do
    name
    shop_id 1
    branch_id 1
    min_reservation_price 0
    reservation_price_percent 100
    reservation_price 100
    tables_count_for_reservation 1
    after :create do |table_zone|
      table_zone.reservation_time_points.create(time_point: "12:00")
    end
    factory :table_zone_with_tables, class: Ddt::TableZone do
      transient do
        tables_count 1
      end
      after :create do |table_zone, evaluator|
        create_list :table, evaluator.tables_count, table_zone: table_zone, shop_id: table_zone.shop_id, branch_id: table_zone.branch_id
      end
    end
  end
end
