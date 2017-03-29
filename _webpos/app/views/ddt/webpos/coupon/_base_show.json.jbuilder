version = coupon.abstract_coupon_version
json.id coupon.id
json.extract! version, :name, :description, :branch_id, :norminal_value_in_currency, :coupon_min_usable_amount_in_currency, :value_desc
json.usage_instructions version.coupon_usage_instructions.map(&:content)
