version = coupon.abstract_coupon_version
json.extract! coupon, :id, :expires_at, :applied_at, :refund_at, :usable_starts_at, :usable_expires_at
json.expired coupon.expired?
json.branch_names version.branch_names rescue nil
json.extract! version, :name, :description
json.photo version.coupon_photos.first.image.thumb_square.url rescue nil
json.exchange_code coupon.exchange_code.try(:code)
