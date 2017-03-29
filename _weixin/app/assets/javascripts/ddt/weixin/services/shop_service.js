Ddt.factory('ShopService',
    ['DdtConst',
    function (DdtConst) {
    var shop = JSON.parse($('meta[name="shop_json"]').attr("content"));
    function get(success){
      success(shop);
    }

    function get_pay_methods(pay_method_setting){
      var btns = Base.newBtns();
      if(shop.is_support_alipay && pay_method_setting.alipay){
        btns.push({ label: '支付宝', value: 'alipay', img: '/images/ddt/my/alipay.png'})
      }
      if(shop.is_support_wechatpay && pay_method_setting.wechatpay){
        btns.push({ label: '微信支付', value: 'wechatpay', img: '/images/ddt/my/wechat_pay.png'})
      }
      if(shop.is_support_baidupay && pay_method_setting.baidupay){
        btns.push({ label: '百度钱包', value: 'baidupay', img: '/images/ddt/my/baidu_pay.png'})
      }
      if(pay_method_setting.pay_on_face){
        btns.push({ label: '现金结账', value: 'pay_on_face', img: '/images/ddt/my/pay_on_face.png'})
      }
      if(pay_method_setting.pay_on_arrive){
        btns.push({ label: '到店付款', value: 'pay_on_arrive', img: '/images/ddt/my/pay_on_face.png'})
      }
      if(pay_method_setting.pay_on_receive){
        btns.push({ label: '货到付款', value: 'pay_on_receive', img: '/images/ddt/my/pay_on_face.png'})
      }
      if(pay_method_setting.vip_card_pay){
        btns.push({ label: '会员卡支付', value: 'vip_card_pay', img: '/images/ddt/my/vip_pay.png'})
      }
      if(pay_method_setting.bank_card_pay){
        btns.push({ label: '银行卡', value: 'bank_card_pay', img: '/images/ddt/my/bank_pay.png'})
      }
      return btns
    }

    function get_branch_type(branch_type_id, success){
        get(function(shop){
          angular.forEach(shop.branch_types, function(branch_type){
            if(branch_type.id === branch_type_id){
              success(branch_type);
            }
          })
        });
      }

    return {
      get: get,
      get_branch_type: get_branch_type,
      get_pay_methods: get_pay_methods
    }
}]);
