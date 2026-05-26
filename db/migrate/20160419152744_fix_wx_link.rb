class FixWxLink < ActiveRecord::Migration
  def change

    execute <<-SQL
      UPDATE ddt_articles
      SET url = CASE
        WHEN url ~ '_ng_path=%2Fuser%2Fprofile$|_ng_path=%2Fuser%2Fvip-info$|_ng_path=%2Fuser%2Fscan-code$|_ng_path=%2Fsign_records$|_ng_path=%2Fuser%2Fcoupon_nav$|_ng_path=%2Fwechat_share_records$|_ng_path=%2Fuser%2F.+%2F[0-9]+$' THEN 'http://cy.diandantong.com' || REPLACE(url, '?', '/my?')
        WHEN url ~ '_ng_path=%2Fbranches%2F[0-9]+%2Fguest_queue$|_ng_path=%2Fbranches%2F[0-9]+%2Fguest_queues%2Fnew_guest$' THEN 'http://cy.diandantong.com' || REPLACE(url, '?', '/queue?')
        WHEN url ~ '_ng_path=%2Fbranches%2F[0-9]+%2Fproducts%2Fdelivery$|_ng_path=%2Fbranches%2F[0-9]+%2Freservation_time_points$|_ng_path=%2Fbranches%2F[0-9]+%2Fproducts%2Fdelivery$|_ng_path=%2Fbranches%2F[0-9]+%2Fpay_online$|_ng_path=%2Fbranches%2F[0-9]+%2Fproducts%2Ffastfood$' THEN 'http://cy.diandantong.com' || REPLACE(url, '?', '/cart?')
        WHEN url ~ '_ng_path=%2Forders%2Fnav$|_ng_path=%2Fbranches%2F[0-9]+%2Forders%2F.+%2F[0-9]+$' THEN 'http://cy.diandantong.com' || REPLACE(url, '?', '/order?')
        WHEN url ~ '_ng_path=%2F$|_ng_path=%2Fbranches%2F[0-9]+$|_ng_path=%2Fpromotions$|_ng_path=%2Ftuans$|_ng_path=%2Frecharge_products$|_ng_path=%2Fmerchant_apply$|_ng_path=%2Fnearby_branch$|_ng_path=%2Fpromotions%2F[0-9]+$|_ng_path=%2Farticles%2F[0-9]+$|_ng_path=%2Fdelivery_branches|_ng_path=%2Fbranches' THEN 'http://cy.diandantong.com' || REPLACE(url, '?', '/main?')
        ELSE url
      END
      WHERE url LIKE '/weixin/shops%';
    SQL

    execute <<-SQL
      UPDATE ddt_home_usable_links
      SET link = CASE
        WHEN link ~ '^#/branches/[0-9]+/guest_queue$|^#/branches/[0-9]+/guest_queues/new_guest$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/queue?' || link
        WHEN link ~ '^#/user/profile$|^#/user/vip-info$|^#/user/scan-code$|^#/sign_records$|^#/user/coupon_nav$|^#/wechat_share_records$|^#/user/.+/[0-9]+$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/my?' || link
        WHEN link ~ '^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/reservation_time_points$|^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/pay_online$|^#/branches/[0-9]+/products/fastfood$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/cart?' || link
        WHEN link ~ '^#/orders/nav$|^#/branches/[0-9]+/orders/.+/[0-9]+$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/order?' || link
        WHEN link ~ '^#/$|^#/branches/[0-9]+$|^#/promotions$|^#/tuans$|^#/recharge_products$|^#/merchant_apply$|^#/nearby_branch$|^#/promotions/[0-9]+$|^#/articles/[0-9]+$|^#/delivery_branches|^#/branches' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/main?' || link
        ELSE link
      END
      WHERE link LIKE '#/%';
    SQL

    execute <<-SQL
      UPDATE ddt_home_hot_links
      SET link = CASE
        WHEN link ~ '^#/branches/[0-9]+/guest_queue$|^#/branches/[0-9]+/guest_queues/new_guest$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/queue?' || link
        WHEN link ~ '^#/user/profile$|^#/user/vip-info$|^#/user/scan-code$|^#/sign_records$|^#/user/coupon_nav$|^#/wechat_share_records$|^#/user/.+/[0-9]+$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/my?' || link
        WHEN link ~ '^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/reservation_time_points$|^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/pay_online$|^#/branches/[0-9]+/products/fastfood$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/cart?' || link
        WHEN link ~ '^#/orders/nav$|^#/branches/[0-9]+/orders/.+/[0-9]+$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/order?' || link
        WHEN link ~ '^#/$|^#/branches/[0-9]+$|^#/promotions$|^#/tuans$|^#/recharge_products$|^#/merchant_apply$|^#/nearby_branch$|^#/promotions/[0-9]+$|^#/articles/[0-9]+$|^#/delivery_branches|^#/branches' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/main?' || link
        ELSE link
      END
      WHERE link LIKE '#/%';
    SQL

    execute <<-SQL
      UPDATE ddt_branch_sliders
      SET url = CASE
        WHEN url ~ '^#/branches/[0-9]+/guest_queue$|^#/branches/[0-9]+/guest_queues/new_guest$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/queue?' || url
        WHEN url ~ '^#/user/profile$|^#/user/vip-info$|^#/user/scan-code$|^#/sign_records$|^#/user/coupon_nav$|^#/wechat_share_records$|^#/user/.+/[0-9]+$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/my?' || url
        WHEN url ~ '^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/reservation_time_points$|^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/pay_online$|^#/branches/[0-9]+/products/fastfood$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/cart?' || url
        WHEN url ~ '^#/orders/nav$|^#/branches/[0-9]+/orders/.+/[0-9]+$' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/order?' || url
        WHEN url ~ '^#/$|^#/branches/[0-9]+$|^#/promotions$|^#/tuans$|^#/recharge_products$|^#/merchant_apply$|^#/nearby_branch$|^#/promotions/[0-9]+$|^#/articles/[0-9]+$|^#/delivery_branches|^#/branches' THEN 'http://cy.diandantong.com/weixin/shops/' || shop_id::text || '/main?' || url
        ELSE url
      END
      WHERE url LIKE '#/%';
    SQL

  end
end
