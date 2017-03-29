angular.module('ddt_app.controllers.rounte_not_found', [])
.controller('routeNotFoundController',
  ['$rootScope', '$timeout', function($rootScope, $timeout){

    console.log("哎呀，迷路了："+window.location.href);

    var legacy_route = {
      cart: [/\/branches\/\d+\/reservation_time_points/,/\/branches\/\d+\/products\/delivery/,/\/branches\/\d+\/products\/eat_in_hall/,/\/branches\/\d+\/products\/reservation/,/\/branches\/\d+\/products\/queue_pre_ordering/,/\/branches\/\d+\/products\/fastfood/,/\/branches\/\d+\/products\/search/,/\/branches\/\d+\/products\/\d+/,/\/branches\/\d+\/orders\/\d+\/\w*\/append_combo/,/\/branches\/\d+\/orders\/delivery\/new/,/\/branches\/\d+\/orders\/eat_in_hall\/new/,/\/branches\/\d+\/orders\/fastfood\/new/,/\/branches\/\d+\/orders\/reservation\/new/,/\/branches\/\d+\/orders\/groupon\/new/,/\/branches\/\d+\/orders\/recharge\/new/,/\/branches\/\d+\/order_success\/\d+\/\w*/,/\/branches\/\d+\/orders\/\d+\/\w*\/append_itemable/,/\/addresses/,/\/addresses\/new/,/\/addresses\/\d+\/edit/,/\/addresses\/\d+\/chose_location/,/\/addresses\/chose_location/,/\/branches\/\d+\/pay_online/,/\/branches\/\d+\/tables\/\d+/,/\/branches\/\d+\/tables\/\d+\/merge_order_itemables/,/\/recharge_products/],
      order: [/\/orders\/nav/,/\/orders\/delivery/,/\/orders\/reservation/,/\/orders\/eat_in_hall/,/\/orders\/fastfood/,/\/orders\/groupon/,/\/orders\/recharge/,/\/orders\/payment/,/\/branches\/\d+\/orders\/delivery\/\d+/,/\/branches\/\d+\/orders\/reservation\/\d+/,/\/branches\/\d+\/orders\/eat_in_hall\/\d+/,/\/branches\/\d+\/orders\/fastfood\/\d+/,/\/branches\/\d+\/orders\/groupon\/\d+/,/\/branches\/\d+\/orders\/recharge\/\d+/,/\/branches\/\d+\/orders\/payment\/\d+/,/\/branches\/\d+\/orders\/\w*\/\d+\/invoice/,/\/branches\/\d+\/orders\/\w*\/\d+\/deliveryman_location/,/\/branches\/\d+\/orders\/invitation\/\d+/,/\/branches\/\d+\/orders\/\d+\/comment/,/\/branches\/\d+\/orders\/\d+\/comment\/new/,/\/exchange_codes\/\d+/],
      my: [/\/user\/profile/,/\/user\/vip-info/,/\/user\/scan-code/,/\/user\/update-vip-info/,/\/user\/update-pay-password/,/\/user\/bind-vip/,/\/user\/card-wallet-log/,/\/favorite_branches/,/\/sign_records/,/\/user\/coupon_nav/,/\/user\/coupons/,/\/user\/coupons\/\d+/,/\/user\/groupons/,/\/user\/groupons\/\d+/,/\/user\/vouchers/,/\/user\/vouchers\/\d+/,/\/user\/sharable_coupons/,/\/user\/sharable_coupons\/\d+/,/\/sharable_coupons\/\d+/,/\/wechat_share_records/,/\/wechat_share_records\/\d+/],
      queue: [/\/branches\/\d+\/guest_queue/,/\/branches\/\d+\/guest_queues\/new_guest/,/\/branches\/\d+\/guest_queue_qr_code\/\d+/],
      main: [/\/branches/,/\/delivery_branches/,/\/branches\/\d+/,/\/branches\/\d+\/introduction/,/\/branches\/\d+\/combos/,/\/promotions/,/\/promotions\/\d+/,/\/branches\/\d+\/comments/,/\/search/,/\/articles\/\d+/,/\/tuans/,/\/tuans\/\d+/,/\/censor-report/,/\/merchant_apply/,/\/contact_us/]
    }

    function right_page(url){
      var k = null;
      for(k in legacy_route){
        var result = legacy_route[k].some(function(r){
          return r.test(url)
        })
        if(result){
          return k
        }
      }
    }

    function current_page(path){
      if ((/\/weixin\/shops\/\w+$/).test(path))
        return 'main'
      else if((/\/weixin\/shops\/\w+\/\w+$/).test(path))
        return path.match(/\/weixin\/shops\/\w+\/(\w+)$/)[1]
      else
        return null
    }

    var current_page = current_page(window.location.pathname)
    var right_page = right_page(window.location.href)

    if(right_page && right_page!=current_page){
      var _ng_path = UrlParser.query_parameter('_ng_path')
      if(!window.location.hash){
        $rootScope.go_page(right_page, _ng_path)
      }else{
        $rootScope.go_page(right_page, window.location.hash)
      }
    }else{
      $timeout(function(){
        $rootScope.go_page('main', '/')
      }, 3000)
    }

  }])
