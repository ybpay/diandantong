class FixWxLink < ActiveRecord::Migration
  def change

    execute <<-SQL
      update ddt_articles
      set url=if(url REGEXP '_ng_path=%2Fuser%2Fprofile$|_ng_path=%2Fuser%2Fvip-info$|_ng_path=%2Fuser%2Fscan-code$|_ng_path=%2Fsign_records$|_ng_path=%2Fuser%2Fcoupon_nav$|_ng_path=%2Fwechat_share_records$|_ng_path=%2Fuser%2F.+%2F[0-9]+$', CONCAT('http://cy.diandantong.com', REPLACE(url, '?', '/my?') ), if(url REGEXP '_ng_path=%2Fbranches%2F[0-9]+%2Fguest_queue$|_ng_path=%2Fbranches%2F[0-9]+%2Fguest_queues%2Fnew_guest$', CONCAT('http://cy.diandantong.com', REPLACE(url, '?', '/queue?') ), if(url REGEXP '_ng_path=%2Fbranches%2F[0-9]+%2Fproducts%2Fdelivery$|_ng_path=%2Fbranches%2F[0-9]+%2Freservation_time_points$|_ng_path=%2Fbranches%2F[0-9]+%2Fproducts%2Fdelivery$|_ng_path=%2Fbranches%2F[0-9]+%2Fpay_online$|_ng_path=%2Fbranches%2F[0-9]+%2Fproducts%2Ffastfood$', CONCAT('http://cy.diandantong.com', REPLACE(url, '?', '/cart?') ), if(url REGEXP '_ng_path=%2Forders%2Fnav$|_ng_path=%2Fbranches%2F[0-9]+%2Forders%2F.+%2F[0-9]+$', CONCAT('http://cy.diandantong.com', REPLACE(url, '?', '/order?') ), if(url REGEXP '_ng_path=%2F$|_ng_path=%2Fbranches%2F[0-9]+$|_ng_path=%2Fpromotions$|_ng_path=%2Ftuans$|_ng_path=%2Frecharge_products$|_ng_path=%2Fmerchant_apply$|_ng_path=%2Fnearby_branch$|_ng_path=%2Fpromotions%2F[0-9]+$|_ng_path=%2Farticles%2F[0-9]+$|_ng_path=%2Fdelivery_branches|_ng_path=%2Fbranches', CONCAT('http://cy.diandantong.com', REPLACE(url, '?', '/main?') ), url)))))
      where url like '/weixin/shops%';
    SQL

    execute <<-SQL
      update ddt_home_usable_links
      set link=if(link REGEXP '^#/branches/[0-9]+/guest_queue$|^#/branches/[0-9]+/guest_queues/new_guest$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/queue?', link), if(link REGEXP '^#/user/profile$|^#/user/vip-info$|^#/user/scan-code$|^#/sign_records$|^#/user/coupon_nav$|^#/wechat_share_records$|^#/user/.+/[0-9]+$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/my?', link), if(link REGEXP '^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/reservation_time_points$|^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/pay_online$|^#/branches/[0-9]+/products/fastfood$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/cart?', link), if(link REGEXP '^#/orders/nav$|^#/branches/[0-9]+/orders/.+/[0-9]+$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/order?', link), if(link REGEXP '^#/$|^#/branches/[0-9]+$|^#/promotions$|^#/tuans$|^#/recharge_products$|^#/merchant_apply$|^#/nearby_branch$|^#/promotions/[0-9]+$|^#/articles/[0-9]+$|^#/delivery_branches|^#/branches', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/main?', link), link)))))
      where link like '#/%';
    SQL

    execute <<-SQL
      update ddt_home_hot_links
      set link=if(link REGEXP '^#/branches/[0-9]+/guest_queue$|^#/branches/[0-9]+/guest_queues/new_guest$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/queue?', link), if(link REGEXP '^#/user/profile$|^#/user/vip-info$|^#/user/scan-code$|^#/sign_records$|^#/user/coupon_nav$|^#/wechat_share_records$|^#/user/.+/[0-9]+$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/my?', link), if(link REGEXP '^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/reservation_time_points$|^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/pay_online$|^#/branches/[0-9]+/products/fastfood$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/cart?', link), if(link REGEXP '^#/orders/nav$|^#/branches/[0-9]+/orders/.+/[0-9]+$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/order?', link), if(link REGEXP '^#/$|^#/branches/[0-9]+$|^#/promotions$|^#/tuans$|^#/recharge_products$|^#/merchant_apply$|^#/nearby_branch$|^#/promotions/[0-9]+$|^#/articles/[0-9]+$|^#/delivery_branches|^#/branches', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/main?', link), link)))))
      where link like '#/%';
    SQL

    execute <<-SQL
      update ddt_branch_sliders
      set url=if(url REGEXP '^#/branches/[0-9]+/guest_queue$|^#/branches/[0-9]+/guest_queues/new_guest$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/queue?', url), if(url REGEXP '^#/user/profile$|^#/user/vip-info$|^#/user/scan-code$|^#/sign_records$|^#/user/coupon_nav$|^#/wechat_share_records$|^#/user/.+/[0-9]+$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/my?', url), if(url REGEXP '^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/reservation_time_points$|^#/branches/[0-9]+/products/delivery$|^#/branches/[0-9]+/pay_online$|^#/branches/[0-9]+/products/fastfood$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/cart?', url), if(url REGEXP '^#/orders/nav$|^#/branches/[0-9]+/orders/.+/[0-9]+$', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/order?', url), if(url REGEXP '^#/$|^#/branches/[0-9]+$|^#/promotions$|^#/tuans$|^#/recharge_products$|^#/merchant_apply$|^#/nearby_branch$|^#/promotions/[0-9]+$|^#/articles/[0-9]+$|^#/delivery_branches|^#/branches', CONCAT('http://cy.diandantong.com/weixin/shops/', shop_id, '/main?', url), url)))))
      where url like '#/%';
    SQL

  end
end
