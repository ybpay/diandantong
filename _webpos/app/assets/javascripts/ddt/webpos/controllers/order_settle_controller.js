WebposModules.add_controller('order_settle')
angular.module('webpos.controllers.order_settle', []).
  controller('orderSettleController',
    ['$rootScope','$scope','$routeParams','$timeout', '$location', '$interval', 'OrderService','BranchService','BaseOrderService','WirePrinterService','PrintService','VipInfoService','CouponService','VoucherService','CardReaderService','CustomerDisplayService','PayItemService','RefreshService','ExtendedFormService','NotifyService', 'SetDiscountPlanAction','TableService', 'HotkeyService', 'CashBoxSettingService', 'TickAccountService', "LocalStorageCache", 'SetFastfoodExtendedForm',
    function($rootScope, $scope, $routeParams,$timeout, $location, $interval, OrderService, BranchService, BaseOrderService,WirePrinterService,PrintService,VipInfoService,CouponService,VoucherService,CardReaderService,CustomerDisplayService, PayItemService,RefreshService,ExtendedFormService,NotifyService, SetDiscountPlanAction, TableService, HotkeyService, CashBoxSettingService, TickAccountService, LocalStorageCache, SetFastfoodExtendedForm){
      $scope.order_id = $routeParams.order_id;
      $scope.order = null;
      $scope.order_type = $routeParams.order_type;
      $scope.pay_methods = [];
      $scope.builtin_pay_methods = [];
      $scope.custom_pay_methods = [];
      $scope.pay_method_page = 1;

      $rootScope.set_last_order_settle_time()
      RefreshService.add($scope, set_menu_height, 100)
      function set_menu_height(){
        $('.sp-content').css({height: "" + ($('.settle-promotions').height() - 46 * 5 - 41) + "px"});
      }

      NotifyService.set_message_hander_in_scope($scope, "PAY_SUCCESS", function(message){
        if(message.order_id == $scope.order_id){
          angular.forEach($scope.order.pay_items, function(pay_item){
            if(pay_item.name_sym == 'alipay_offline' ||
               pay_item.name_sym == 'wechatpay_offline' ||
               pay_item.name_sym == 'alipay' ||
               pay_item.name_sym == 'wechatpay'
              ){
              $scope.refresh_pay_item_state(pay_item)
            }
          })
        }
      });

      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        $rootScope.play_subscribe_voice();

        // pay_methods
        $scope.pay_methods = $scope.branch.pay_methods.filter(function(pay_method){
          return pay_method["support_" + $scope.order_type]
        })

        var service = BaseOrderService.get_resource($scope.order_type)
        var check_moling = $scope.branch.moling_auto;
        service.get({branch_id: $scope.branch_id, id: $scope.order_id, check_moling: check_moling}).$promise.then(function(order){
          $scope.order = order
          if($scope.order.vip_info){
            VipInfoService.set_bind($scope.order.vip_info.id, $scope.order)
            VipInfoService.get($scope.order.vip_info.id, function(vip_info){
              $scope.vip_modal.vip_info = vip_info;
            })
          }
          if(order.pay_item_state == 'paid' || order.state == 'completed' || order.state == 'canceled'){
            $rootScope.go_branch($scope.branch)
            // 回跳需要给出友好的提示
            var alertMessage;
            switch(order.pay_item_state){
              case 'paid':      alertMessage = "订单已支付"; break;
              case 'completed': alertMessage = "订单已完成"; break;
              case 'canceled':  alertMessage = "订单已取消"; break;
            }
            $rootScope.alert(alertMessage);
            return
          }
          $scope.builtin_pay_methods = $scope.pay_methods.filter(function(p){
            return p.builtin &&
                  ['baidupay'].indexOf(p.name_sym) == -1 &&
                  !(order.type_str != "delivery" && p.name_sym == 'pay_on_receive') &&
                  !(order.type_str != "reservation" && p.name_sym == 'pay_on_arrive')
          })
          $scope.custom_pay_methods = $scope.pay_methods.filter(function(p){ return !p.builtin })
          refresh_placed_time()
          if($scope.is_fast_food()){
            // 如果订单没有的支付方式,就使用这个 modal
            if ($scope.order.pay_items.length == 0) {
              $scope.pay_item_selection_modal.open();
            }
          }
        })
      })

      // 开台时间
      RefreshService.add($scope, refresh_placed_time, 60000)
      function refresh_placed_time(){
        if($scope.order && $scope.order.placed_at){
          $scope.placed_time_str = $rootScope.time_since_from($scope.order.placed_at)
        }
      }

      $scope.is_vip = function(need_alert){
        if($scope.order){
          if($scope.order.vip_info){
            if(!$scope.order.vip_info.is_default){
              return true
            }else{
              if(need_alert){ $rootScope.alert("该用户不是会员用户。") }
            }
          }else{
            if(need_alert){ $rootScope.alert("请先点击'会员识别'绑定会员.") }
          }
        }
        return false
      }

      function jump_back(){
        var after_settle_full_path = LocalStorageCache.get("after_settle_full_path")
        if(after_settle_full_path && after_settle_full_path != ""){
          LocalStorageCache.set("after_settle_full_path", null)
          $rootScope.go_path(after_settle_full_path)
        }else{
          if($rootScope.after_settle_url){
            $rootScope.go($rootScope.after_settle_url);
          }else{
            $rootScope.go_branch($scope.branch);
          }
        }
      }

      $scope.change_vip_info = function(vip_info_id, callback){
        BaseOrderService.change_vip_info($scope.order_type, $scope.branch_id, $scope.order.id, vip_info_id, function(order){
          VipInfoService.set_bind(vip_info_id, order)
          $scope.order = order
          if(callback){callback()}
        })
      }

      $scope.rollback_coupon = function(){
        $rootScope.confirm("确定取消应用该优惠券？", function(){
          BaseOrderService.rollback_coupon($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
            $scope.order = order
          })
        })
      }

      $scope.rollback_voucher = function(){
        $rootScope.confirm("确定取消应用该代金券？", function(){
          BaseOrderService.rollback_voucher($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
            $scope.order = order
          })
        })
      }

      $scope.cancel_privilege_discount = function(){
        $rootScope.auth_action("branch", "order", "cancel_privilege_discount", { branch_id: $scope.branch_id }, function(){
          $rootScope.confirm("确定取消权限折扣？", function(){
            BaseOrderService.cancel_privilege_discount($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
              $rootScope.clear_authorizer()
              $scope.order = order
              $scope.total_after_privilege = $scope.order.total
            })
          })
        })
      }

      $scope.cancel_privilege_reduction = function(){
        $rootScope.auth_action("branch", "order", "cancel_privilege_discount", { branch_id: $scope.branch_id }, function(){
          $rootScope.confirm("确定取消权限减免？", function(){
            BaseOrderService.cancel_privilege_reduction($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
              $rootScope.clear_authorizer()
              $scope.order = order
              $scope.total_after_privilege = $scope.order.total
            })
          })
        })
      }

      $scope.cancel_privilege_free = function(){
        $rootScope.auth_action("branch", "order", "cancel_privilege_discount", { branch_id: $scope.branch_id }, function(){
          $rootScope.confirm("确定取消免单？", function(){
            BaseOrderService.cancel_privilege_free($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
              $rootScope.clear_authorizer()
              $scope.order = order
              $scope.total_after_privilege = $scope.order.total
            })
          })
        })
      }

      $scope.privilege_free = function(){
        try_privilege_promotion(function(){
          $rootScope.confirm("确定免单?", function(){
            BaseOrderService.privilege_free($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
              $scope.order = order
              $rootScope.clear_authorizer()
              if($scope.order.pay_items.length == 0){
                var pay_method = $scope.builtin_pay_methods[0]
                $scope.pay_items = [{
                  id:       pay_method.id,
                  name:     pay_method.name,
                  name_sym: pay_method.name_sym,
                  amount:   0
                }]
              }
            })
          })
        })
      }

      // vip_modal
      $scope.vip_modal = {
        // 微信扫码
        read_qrcode: function(){
          $rootScope.vip_scan_verify("微信扫码识别", "请顾客用微信扫描下面的二维码", function(vip_info){
            ExtendedFormService.show_order($scope.order.id)
            if(vip_info.is_default){
              $rootScope.alert("该用户还不是会员");
            }else{
              $scope.vip_modal.vip_info = vip_info
              $scope.vip_modal.submit()
            }
          }, true, true)
        },

        // 会员搜索
        search_show: false,
        search_key: null,
        vip_infos: [],
        chosen_vip_info: null,
        search_open: function(){ this.search_show = true; },
        search_confirm: function(){
          this.vip_info = this.chosen_vip_info;
          this.search_show = false;
          this.submit()
        },
        search_close: function(){
          this.search_show = false;
        },
        search_select: function(vip_info){
          this.chosen_vip_info = vip_info;
        },
        search_vip_info: function(){
          params = {per_page: 7}
          params["q[vip_no_or_phone_or_name_cont]"] = this.search_key;
          VipInfoService.query(params, function(vip_infos){
            $scope.vip_modal.vip_infos = vip_infos;
          })
        },

        vip_info: null,
        can_submit: function(){
          return this.vip_info
        },
        submit: function(){
          if(this.can_submit()){
            $scope.change_vip_info(this.vip_info.id, function(){
              $rootScope.alert("绑定成功")
            })
          }
        },
        read_card: function(){
          var This = this;
          CardReaderService.read($rootScope.shop.card_key).then(function(vip_no){
            if (vip_no){
              This.find_vip_info(vip_no)
            }else{
              $rootScope.alert("读卡失败")
            }
          })
        },
        find_vip_info: function(vip_no_or_id){
          VipInfoService.get(vip_no_or_id, function(vip_info){
            $scope.vip_modal.vip_info = vip_info
            $scope.vip_modal.submit()
          })
        },
        scan_code: function(){
          $rootScope.scan("会员付款码识别", "请顾客出示微信会员付款码，将扫描枪对准进行扫描。(注：扫描枪分一维码/二维码以及光敏/纸质类型，请灵活选择)", function(code){
            ExtendedFormService.show_order($scope.order.id)
            if(code){
              VipInfoService.get_by_scan_code(code, function(vip_info){
                $scope.vip_modal.vip_info = vip_info
                $scope.vip_modal.submit()
              })
            }
          })
        }
      }

      var search_vip_info_select = function(e){
        if($scope.vip_modal.search_show && e.keyCode == 13){
          $scope.vip_modal.search_vip_info()
        }
      }
      $(document).on("keydown", search_vip_info_select)
      $scope.$on("$destroy", function(){
        $(document).off("keydown", search_vip_info_select)
      })

      $scope.unbind_vip_info = function(){
        $rootScope.confirm("确定解除该会员与订单的绑定？", function(){
          if($scope.order.vip_info){
            VipInfoService.set_bind($scope.order.vip_info.id, undefined);
            BaseOrderService.unbind_vip_info($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
              $scope.order = order;
              $scope.vip_modal.vip_info = null;
            })
          }
        })

      }

      $scope.privilege_promotion = function(){
        return $scope.order && ($scope.order.privilege_discount || $scope.order.privilege_reduction || $scope.order.privilege_free)
      }

      function alert_has_promotion(){
        $rootScope.alert("一个订单只能享受一个权限优惠，若要更改，请先清除之前的权限优惠");
      }

      $scope.discount_modal = {
        discount: null,
        disable_discount_amount: 0.0,
        discount_percent: null,
        open: function(success){
          try_privilege_promotion(success)
        },
        can_submit: function(){
          return this.discount && parseFloat(this.discount) >= 0 && parseFloat(this.discount) < 1 && parseFloat(this.disable_discount_amount) >= 0
        },
        submit: function(){
          if(this.can_submit()){
            BaseOrderService.privilege_discount($scope.order_type, $scope.branch_id, $scope.order.id, $scope.discount_modal.discount, $scope.discount_modal.disable_discount_amount, function(order){
              // console.log('after discount: '+order.total)
              $scope.order = order
              $rootScope.clear_authorizer()
              $scope.discount_modal.discount = null
              $scope.discount_modal.disable_discount_amount = 0.0
              $scope.discount_modal.discount_percent = null;
              $scope.toggle_menu_key('hysb')
            })
          }else{
            $rootScope.alert("输入金额非法")
          }
        }
      }

      var clear_watch_discount_percent = $scope.$watch("discount_modal.discount_percent", function(value){
        $scope.discount_modal.discount = parseFloat(value) / 100
      })

      $scope.reduction_modal = {
        reduce_amount: null,
        open: function(success){
          try_privilege_promotion(success)
        },
        can_submit: function(){
          return this.reduce_amount && parseFloat(this.reduce_amount) >=0  && parseFloat(this.reduce_amount) <= parseFloat($scope.order.total)
        },
        submit: function(){
          if(this.can_submit()){
            BaseOrderService.privilege_reduction($scope.order_type, $scope.branch_id, $scope.order.id, this.reduce_amount, function(order){
              $scope.order = order
              $rootScope.clear_authorizer()
              $scope.reduction_modal.reduce_amount = null
              $scope.toggle_menu_key('hysb')
            })
          }else{
            $rootScope.alert("输入金额非法");
          }
        }
      }

      function try_privilege_promotion(success){
        if($scope.privilege_promotion()){alert_has_promotion();return}
        if(parseFloat($scope.order.item_total_for_discount) == 0){
          $rootScope.alert("该订单无法参与权限折扣");
          return;
        }
        $rootScope.auth_action("branch", "order", "privilege_discount", {branch_id: $scope.branch_id}, success)
      }

      var watch_privilege_discount = function(){
        if($scope.order && $scope.discount_modal.can_submit()){
          var order_total = parseFloat($scope.order.total);
          var item_total_for_discount = parseFloat($scope.order.item_total_for_discount);
          var discount = parseFloat($scope.discount_modal.discount);
          var disable_discount_amount = parseFloat($scope.discount_modal.disable_discount_amount)
          $scope.total_after_privilege = (order_total - (item_total_for_discount - disable_discount_amount)*(1 - discount)).toFixed(2);
        }else{
          if($scope.order){
            $scope.total_after_privilege = $scope.order.total
          }
        }
      }
      var clear_watch_discount = $scope.$watch('discount_modal.discount', watch_privilege_discount)
      var clear_watch_disable_discount_amount = $scope.$watch('discount_modal.disable_discount_amount', watch_privilege_discount)

      var clear_watch_reduce_amount = $scope.$watch('reduction_modal.reduce_amount', function(){
        if($scope.order && $scope.reduction_modal.can_submit()){
          $scope.total_after_privilege = (parseFloat($scope.order.total) - parseFloat($scope.reduction_modal.reduce_amount)).toFixed(2);
        }else{
          if($scope.order){
            $scope.total_after_privilege = $scope.order.total
          }
        }
      })

      $scope.coupon_modal = {
        code: null,
        coupon: null,
        search_coupon: function(){
          CouponService.search($scope.branch_id, this.code, function(coupon){
            $scope.coupon_modal.coupon = coupon
          })
        },
        scan_code: function(){
          $rootScope.scan("扫码验券", "请顾客出示优惠券二维码，将扫描枪对准进行扫描。(注：扫描枪分一维码/二维码以及光敏/纸质类型，请灵活选择)", function(code){
            $scope.coupon_modal.code = code
            $scope.coupon_modal.search_coupon()
          })
        },
        can_submit: function(){
          return this.coupon
        },
        submit: function(){
          if(this.can_submit()){
            BaseOrderService.apply_coupon($scope.order_type, $scope.branch_id, $scope.order.id, this.coupon.id, function(order){
              $scope.order = order
            })
          }
        }
      }

      $scope.voucher_modal = {
        show: false,
        code: null,
        voucher: null,
        open: function(){ this.show = true },
        close: function(){
          this.show = false;
          this.code = null;
          this.voucher = null;
        },
        search_voucher: function(){
          VoucherService.search($scope.branch_id, this.code, function(voucher){
            $scope.voucher_modal.voucher = voucher
          })
        },
        can_submit: function(){
          return this.voucher
        },
        submit: function(){
          if(this.can_submit()){
            BaseOrderService.apply_voucher($scope.order_type, $scope.branch_id, $scope.order.id, this.voucher.id, function(order){
              $scope.order = order
              $scope.voucher_modal.close()
            })
          }
        }
      }

      function print_order_bill(){
        return PrintService.print_order_bill($scope.order)
      }

      // 客显
      var clear_watch_order_total = $scope.$watch("order.total", function(){
        if($scope.order){
          CustomerDisplayService.display_data(2, $scope.order.total)
        }
      })

      $scope.$on("$destroy", function(){
        CustomerDisplayService.display_data(0, '')
      })

      // 支付
      $scope.pay_items = []
      // 支付拼音过滤
      $scope.pay_method_filter_key = ""
      function to_decimal(amount){
        return parseFloat(parseFloat(amount).toFixed(2))
      }
      $scope.pay_items_total = function(){
        var total = 0
        angular.forEach($scope.pay_items, function(pay_item){
          total += parseFloat(pay_item.amount)
        })
        return to_decimal(total)
      }

      function pay_with_method(name_sym){
        if(name_sym == 'vip_card_pay'){
          if($scope.is_vip(true)){
            $scope.pay_item_modal.open_with_name(name_sym)
          }
        }else{
          $scope.pay_item_modal.open_with_name(name_sym)
        }
      }

      $scope.select_pay_method_name = function(name_sym){
        var item = _.find($scope.pay_items, { name_sym: name_sym })
        if($scope.order.pay_items.length > 0){
          $rootScope.alert("该订单已有支付条目, 若想修改支付条目, 请先点击重新结算")
        }else if($scope.pay_items_total() > 0 && $scope.pay_items_total() >= parseFloat($scope.order.total)){
          $rootScope.alert("总支付价格已经大于等于订单总计，不允许继续添加支付方式")
        }else{
          if(item){
            $rootScope.confirm("已有相同的支付条目, 是否继续添加？", function(){
              pay_with_method(name_sym);
            })
          }else {
            pay_with_method(name_sym);
          }
        }
      }

      $scope.select_pay_method = function(pay_method){
        var item = _.find($scope.pay_items, { id: pay_method.id })
        if(item){
          $rootScope.confirm("已有相同的支付条目, 是否继续添加？", function(){
            $scope.pay_item_modal.open_with_pay_method(pay_method)
          })
        }else{
          $scope.pay_item_modal.open_with_pay_method(pay_method)
        }
      }

      $scope.show_builtin_pay_methods = function(){
        return $scope.builtin_pay_methods.filter(function(pay_method){
          return $scope.show_pay_method_name(pay_method.name_sym)
        })
      }

      $scope.show_custom_pay_methods = function(){
        return $scope.custom_pay_methods.filter(function(pay_method){
          return $scope.show_pay_method(pay_method)
        })
      }

      $scope.show_pay_method_name = function(name_sym){
        var pay_method = $scope.pay_methods.filter(function(pay_method){ return pay_method.name_sym == name_sym })[0]
        var support = true
        switch(name_sym){
          case 'wechatpay':
          case 'wechatpay_offline':
            support = $scope.branch && $scope.branch.is_support_wechatpay;
            break;
          case 'alipay':
          case 'alipay_offline':
            support = $scope.branch && $scope.branch.is_support_alipay;
            break;
        }
        return pay_method && support && $scope.show_pay_method(pay_method)
      }

      $scope.show_pay_method = function(pay_method){
        return $scope.show_key(pay_method.name_abbr) || $scope.show_key(pay_method.code)
      }

      $scope.show_key = function(key){
        return $scope.pay_method_filter_key == '' || (key && key.indexOf($scope.pay_method_filter_key) == 0)
      }

      $scope.key_color = function(key){
        var sum = 0;
        for(var i=0;key && i<key.length;i++){
          sum = key.charCodeAt(i)
        }
        return "color- color-" + sum % 10;
      }

      $scope.pay_method_pre_page = function(){
        if($scope.pay_method_page > 1){ $scope.pay_method_page -= 1 }
      }

      $scope.pay_method_next_page = function(){
        var bmt = $scope.show_builtin_pay_methods().length
        var cmt = $scope.show_custom_pay_methods().length
        if($scope.pay_method_page * 8 < bmt + cmt){ $scope.pay_method_page += 1 }
      }

      $scope.show_index = function(index){
        return index >= ($scope.pay_method_page - 1) * 8 && index < $scope.pay_method_page * 8
      }

      $scope.show_custom_index = function(index){
        var bmt = $scope.show_builtin_pay_methods().length
        return $scope.show_index(index + bmt)
      }

      $scope.can_fast_vip_card_pay = function(){
        return $scope.order && $scope.order.vip_info && $scope.order.pay_items.length == 0 && $scope.pay_items.length == 0
      }

      $scope.fast_vip_card_pay = function(){
        var pay_method = $scope.builtin_pay_methods.filter(function(p){ return p.name_sym == "vip_card_pay"})[0]
        $scope.pay_items.push({
          id: pay_method.id,
          name: pay_method.name,
          name_sym: pay_method.name_sym,
          amount: $scope.order.total,
        })
        if($scope.can_settle()){
          $scope.settle()
        }
      }

      $scope.can_settle = function(){
        return $scope.order && !$scope.order.pay_items.length && $scope.pay_items.length > 0 && $scope.pay_items_total() >= parseFloat($scope.order.total)
      }

      $scope.settle = function(options){
        options = options || {}
        if($scope.can_settle()){
          if($scope.pay_items_total() > parseFloat($scope.order.total)){
            $rootScope.alert("支付总额大于订单总额, 不允许结算，请确认支付条目是否正确！")
            // $rootScope.confirm("支付总额大于订单总额, 是否继续结算?", function(){
            //   settle_action(options)
            // })
          }else{
            settle_action(options)
          }
        }
      }

      function settle_action(options){
        options = options || {}
        BaseOrderService.create_pay_items($scope.order_type, $scope.branch_id, $scope.order.id, $scope.pay_items, function(order){
          $scope.order = order;
          $scope.pay_items = [];
          var pay_items_size = $scope.order.pay_items.length;
          if(pay_items_size == 0){
            $rootScope.alert("支付失败，请添加支付方式");
          }
          else if (options.after_create_pay_items) {
            options.after_create_pay_items();
          } else if(pay_items_size == 1){
            // 单支付
            var pay_item = $scope.order.pay_items[0]
            switch(pay_item.name_sym){
              case 'vip_card_pay':
                if(parseFloat($scope.order.vip_info.available_card_wallet_amount) >= parseFloat(pay_item.amount)){
                  $scope.change_pay_item_to_paid(pay_item)
                }else{
                  $rootScope.alert("会员可用余额不足")
                }
                break;
              case 'alipay':
              case 'wechatpay':
                $scope.pay_item_get_pay_online(pay_item)
                break;
              case 'alipay_offline':
              case 'wechatpay_offline':
                $scope.pay_item_pay_by_seller_scan(pay_item)
                break;
              case 'pay_on_face':
                if(CashBoxSettingService.getAutoOpen()){
                  WirePrinterService.open_cashbox();
                }
                $scope.change_pay_item_to_paid(pay_item);
                break;
              default:
                // pay_on_face bank_card_pay custom_pay_method
                $scope.change_pay_item_to_paid(pay_item)
            }
          }else{
            // 组合支付
            var need_pay_platform = false
            angular.forEach($scope.order.pay_items, function(pay_item){
              if(pay_item.pay_platform){ need_pay_platform = true }
            })
            if(!need_pay_platform){
              var text = "确认支付? <br/>"
              angular.forEach($scope.order.pay_items, function(pay_item){
                text += pay_item.name + ": " + pay_item.amount + "<br/>"
              })
              text += "合计:" + $scope.order.pay_item_total.toFixed(2)
              $rootScope.confirm(text, function(){
                BaseOrderService.pay_all_pay_items($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
                  $scope.order = order
                  check_order_paid();
                })
              })
            }
          }
          check_order_paid();
        })
      }

      $scope.pay_item_modal = {
        show: false,
        changed: false,
        pay_method: undefined,
        pay_item: {},
        tick_accounts: [],
        active_tick_account: {},
        open_with_name: function(name_sym){
          this.pay_method = $scope.builtin_pay_methods.filter(function(p){ return p.name_sym == name_sym})[0]
          var name = this.pay_method.name
          this.pay_item = { name: name, name_sym: name_sym, amount: null }
          if(name_sym == "tick_for_account"){
            TickAccountService.query($scope.branch_id, function(resp){
              $scope.pay_item_modal.tick_accounts = resp
            })
          }
          this.open()
        },
        open_with_pay_method: function(pay_method){
          this.pay_method = pay_method
          this.pay_item = { name: pay_method.name, id: pay_method.id, amount: null }
          this.open()
        },
        open: function(){
          $scope.add_money_action = function(amount){
            var current_amount = parseFloat($scope.pay_item_modal.pay_item.amount)
            if(isNaN(current_amount)){
              current_amount = 0;
            }
            $scope.pay_item_modal.pay_item.amount = to_decimal(current_amount) + amount;
            $scope.pay_item_modal.focus();
          }

          if($scope.order){
            this.pay_item.amount = to_decimal(parseFloat($scope.order.total) - $scope.pay_items_total())
            if(this.pay_item.amount < 0){ this.pay_item.amount = 0 }
            this.changed = false
            this.show = true
            $rootScope.select(".pay-item-modal input")
          }
        },
        clear: function(){
          this.pay_item.amount = null
          this.focus();
        },
        focus: function(){
          $rootScope.focus('.pay-item-modal input');
        },
        close: function(){ this.show = false},
        submit: function(){
          if(this.can_submit()){
            $scope.pay_items.push({
              id: this.pay_item.id,
              name: this.pay_item.name,
              name_sym: this.pay_item.name_sym,
              amount: this.pay_item.amount,
              tick_account_id: this.active_tick_account.id
            })
            this.close()
            if($scope.can_settle()){
              $scope.settle()
            }
          }
        },
        can_submit: function(){
          var amount = parseFloat(this.pay_item.amount)
          return $scope.order &&
          ( (amount > 0 || (this.pay_method && this.pay_method.enable_negative) ) ||
            (parseFloat($scope.order.total) == 0 && this.pay_item.name_sym == 'pay_on_face')) &&
          (this.pay_item.name_sym != "tick_for_account" || this.active_tick_account.id != undefined )
        }
      };

      $scope.pay_item_selection_modal = {
        show: false,
        pay_method: undefined,
        changed: false,

        amount: 0,
        paid_amount: 0,
        change: 0,
        pay_item: {},

        open: function(){
          // 初始化为现金支付
          this.pay_method = $scope.builtin_pay_methods.filter(function(p){
            return p.name_sym == 'pay_on_face';
          })[0];
          if (this.pay_method == undefined){
            $rootScope.alert('后台未启用 现金 支付方式');
            return ;
          }
          this.pay_item = {
            name: this.pay_method.name,
            name_sym: this.pay_method.name_sym,
            amount: null
          };

          $scope.add_money_action = function(amount){
            var paid_amount = parseFloat($scope.pay_item_selection_modal.paid_amount)
            if(isNaN(paid_amount)){
              paid_amount = 0;
            }
            $scope.pay_item_selection_modal.paid_amount = to_decimal(paid_amount) + amount;
            $scope.pay_item_selection_modal.focus();
          };

          if($scope.order){
            this.pay_item.amount = to_decimal(parseFloat($scope.order.total))
            if(this.pay_item.amount < 0){
              this.pay_item.amount = 0;
            }
            this.amount = this.pay_item.amount;
            this.changed = false
            this.show = true
            $rootScope.select(".pay-item-selection-modal .paid-amount-group input")
          }
        },
        clear: function(){
          this.paid_amount = null
          this.focus();
        },
        focus: function(){
          $rootScope.focus('.pay-item-selection-modal input');
        },
        close: function(){ this.show = false},

        submit: function(){
          if(this.can_submit()){
            $scope.pay_items.push({
              id: this.pay_item.id,
              name: this.pay_item.name,
              name_sym: this.pay_item.name_sym,
              amount: this.pay_item.amount,
            });
            this.close()
            if($scope.can_settle()){
              var This = this;
              $scope.settle({
                after_create_pay_items: function(){
                  This.pay_item = $scope.order.pay_items[0]
                  if($rootScope.is_submiting){
                    return;
                  }
                  $rootScope.is_submiting = true;
                  if(This.paid_amount - parseFloat(This.pay_item.amount) < 0){
                    This.paid_amount = parseFloat(This.pay_item.amount)
                  }
                  PayItemService.paid($scope.branch_id, $scope.order.id, This.pay_item.id, {
                    paid_amount: to_decimal(parseFloat($scope.pay_item_selection_modal.paid_amount)),
                    change: to_decimal(parseFloat($scope.pay_item_selection_modal.change))
                  }, function(new_pay_item){
                    if(new_pay_item.bill){$scope.order.bill = new_pay_item.bill}
                    $rootScope.is_submiting = false;
                    var pay_item = $scope.pay_item_selection_modal.pay_item
                    pay_item.state = new_pay_item.state
                    pay_item.state_name = new_pay_item.state_name
                    pay_item.paid_amount = new_pay_item.paid_amount
                    pay_item.change = new_pay_item.change
                    update_pay_item(new_pay_item);
                    check_order_paid(true)  // don't jump back
                    $scope.pay_item_selection_modal.close();

                    // 如果是现金支付,显示钱箱及收款详情
                    if (pay_item.name_sym == 'pay_on_face'){
                      if(CashBoxSettingService.getAutoOpen()){
                        WirePrinterService.open_cashbox();
                      }
                      if(!$scope.is_fast_food()){
                        jump_back();
                        $rootScope.alert("结算成功")
                      }else{
                        $scope.pay_on_face_finish_modal.amount = This.amount;
                        $scope.pay_on_face_finish_modal.paid_amount = This.paid_amount;
                        $scope.pay_on_face_finish_modal.change = This.change;
                        $scope.pay_on_face_finish_modal.show = true
                      }
                    }
                  })
                }
              });
            }
          }
        },
        can_submit: function(){
          var amount = parseFloat(this.pay_item.amount)
          return $scope.order &&
            ( (amount > 0 || (this.pay_method && this.pay_method.enable_negative) ) ||
              (parseFloat($scope.order.total) == 0 && this.pay_item.name_sym == 'pay_on_face')
            )
        },

        select_pay_method: function(name_sym){
          this.pay_method = $scope.builtin_pay_methods.filter(function(p){
            return p.name_sym == name_sym;
          })[0];
          this.pay_item = {
            name: this.pay_method.name,
            name_sym: this.pay_method.name_sym,
            amount: this.amount
          };
          $scope.pay_items.push({
            id: this.pay_item.id,
            name: this.pay_item.name,
            name_sym: this.pay_item.name_sym,
            amount: this.pay_item.amount,
          });
          this.close();
          if($scope.can_settle()){
            $scope.settle();
          }
        }
      };

      var clear_watch_paid_amount2 = $scope.$watch('pay_item_selection_modal.paid_amount', function(paid_amount){
        if($scope.pay_item_selection_modal.pay_item){
          var pay_item_amount = parseFloat($scope.pay_item_selection_modal.pay_item.amount)
          if(paid_amount > pay_item_amount){
            $scope.pay_item_selection_modal.change = (paid_amount - pay_item_amount).toFixed(2)
          }else{
            $scope.pay_item_selection_modal.change = 0;
          }
        }
      });

      $scope.pay_on_face_finish_modal = {
        show: false,
        paid_amount: 0,
        amount: 0,
        change: 0,
        close: function(){
          this.show = false
          jump_back();
          $rootScope.alert("结算成功")
        }
      }

      $scope.change_pay_item_to_paid = function(pay_item){
        if (pay_item.name_sym == 'pay_on_face'){
          if (parseFloat($scope.order.total) != 0) {
            $scope.pay_on_face_modal.open(pay_item);
            return;
          }
        }
        var hint;
        if (pay_item.name_sym == 'vip_card_pay') {
          hint = "您确定从会员" + $scope.order.vip_info.name + "的会员卡上扣除" + pay_item.amount + "会员余额";
        }else{
          hint = "确认支付: " + pay_item.name + " " + pay_item.amount;
        }

        $rootScope.confirm(hint, function(){
          PayItemService.paid($scope.branch_id, $scope.order.id, pay_item.id, {}, function(new_pay_item){
            if(new_pay_item.bill){$scope.order.bill = new_pay_item.bill}
            pay_item.state = new_pay_item.state
            pay_item.state_name = new_pay_item.state_name
            check_order_paid()
          })
        })
      }

      $scope.pay_on_face_modal = {
        pay_item: null,
        paid_amount: 0,
        change: 0,
        show: false,
        open: function(pay_item){
          $scope.add_money_action = function(amount){
            var paid_amount = parseFloat($scope.pay_on_face_modal.paid_amount)
            if(isNaN(paid_amount)){
              paid_amount = 0;
            }
            $scope.pay_on_face_modal.paid_amount = to_decimal(paid_amount) + amount;
            $scope.pay_on_face_modal.focus();
          }
          this.paid_amount = null;
          this.pay_item = pay_item;
          this.show = true;
          this.focus();
        },
        clear: function(){
          this.paid_amount = null;
          this.focus();
        },
        focus: function(){
          $rootScope.focus('.pay-on-face-modal input')
        },
        close: function(){
          this.change = 0;
          this.show = false;
        },
        submit: function(){
          if(this.can_submit()){
            if($rootScope.is_submiting){return;}
            $rootScope.is_submiting = true;
            if(this.paid_amount - parseFloat(this.pay_item.amount) < 0){
              this.paid_amount = parseFloat(this.pay_item.amount)
            }
            PayItemService.paid($scope.branch_id, $scope.order.id, this.pay_item.id, {
              paid_amount: to_decimal(parseFloat($scope.pay_on_face_modal.paid_amount)),
              change: to_decimal(parseFloat($scope.pay_on_face_modal.change))
            }, function(new_pay_item){
              if(new_pay_item.bill){$scope.order.bill = new_pay_item.bill}
              $rootScope.is_submiting = false;
              $scope.pay_on_face_modal.pay_item.state = new_pay_item.state
              $scope.pay_on_face_modal.pay_item.state_name = new_pay_item.state_name
              $scope.pay_on_face_modal.pay_item.paid_amount = new_pay_item.paid_amount
              $scope.pay_on_face_modal.pay_item.change = new_pay_item.change
              update_pay_item(new_pay_item);
              check_order_paid()
              $scope.pay_on_face_modal.close();
            })
          }else{
            $rootScope.alert("收取金额不足")
          }
        },
        can_submit: function(){
          if(!this.pay_item){return false }
          return true
        }
      }

      var clear_watch_paid_amount = $scope.$watch('pay_on_face_modal.paid_amount', function(paid_amount){
        if($scope.pay_on_face_modal.pay_item){
          var pay_item_amount = parseFloat($scope.pay_on_face_modal.pay_item.amount)
          if(paid_amount > pay_item_amount){
            $scope.pay_on_face_modal.change = (paid_amount - pay_item_amount).toFixed(2)
          }else{
            $scope.pay_on_face_modal.change = 0;
          }
        }
      });

      function update_pay_item(new_pay_item){
        angular.forEach($scope.order.pay_items, function(pay_item, index){
          if(pay_item.id == new_pay_item.id){
            $scope.order.pay_items[index] = new_pay_item;
          }
        })
      }

      function try_local_print(){
        if($rootScope.local_printer_configed()){
          print_order_bill();
        }
      }

      function try_local_print_and_jump_back(){
        if($rootScope.local_printer_configed()){
          $rootScope.alert("结算成功")
          print_order_bill().then(function(){
            jump_back();
          });
        }else if($scope.branch.webpos_autoprinter_configed){
          $rootScope.alert("结算成功");
          jump_back();
        }else{
          $rootScope.confirm("结算成功，您要打印消费账单？", function(){
            print_order_bill().then(function(){
              jump_back();
            });
          },"确定", function(){
            jump_back();
          })
        }
      }

      function check_order_paid(no_jump_back){
        if(is_order_paid()){
          $rootScope.settled_orders_cache.setItem($scope.order.id, true);
          if($scope.order && $scope.order.type_str == "eat_in_hall"){
            $rootScope.set_cache("order_of_table_"+$scope.order.table_id, $scope.order)
          }
          if($scope.order && $scope.order.vip_info){
            VipInfoService.set_bind($scope.order.vip_info.id, undefined)
          }
          if (no_jump_back) {
            try_local_print();
          } else {
            try_local_print_and_jump_back();
          }

        }
      }

      function is_order_paid(){
        if($scope.order.pay_items.length > 0){
          // check if all paid
          var unpaid_item = _.find($scope.order.pay_items, function(pay_item){
            return pay_item.state != 'paid';
          });
          return unpaid_item == undefined;
        }else{
          return false
        }
      }

      $scope.clear_pay_items = function(){
        $rootScope.confirm("确定重新结算?", function(){
          BaseOrderService.clear_pay_items($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
            // 检查返回值是否成功，如果成功
            $scope.order = order
            pay_method_filter_input_focus()
          })
        })
      }

      $scope.pay_item_get_pay_online = function(pay_item){
        PayItemService.get_pay_online($scope.branch_id, $scope.order.id, pay_item.id, false, function(result){
          if(result.qr_code_url){
            $scope.pay_item_qrcode_modal.current_pay_item = pay_item
            if(pay_item.name_sym == 'alipay'){
              $scope.pay_item_qrcode_modal.hint = "请客户使用支付宝扫描下面的二维码支付"
            }else if(pay_item.name_sym == 'wechatpay'){
              $scope.pay_item_qrcode_modal.hint = "请客户使用微信扫描下面的二维码支付"
            }
            $scope.pay_item_qrcode_modal.qr_code_url = result.qr_code_url
            $scope.pay_item_qrcode_modal.open()
          }else{
            $rootScope.alert("当前支付功能暂不能使用，请让管理员检查后台配置")
          }
        })
      }

      $scope.pay_item_pay_by_seller_scan = function(pay_item){
        var info, info_key;
        if(pay_item.name_sym == 'alipay_offline'){
          info_key = "支付宝"
        }else if(pay_item.name_sym == 'wechatpay_offline'){
          info_key = "微信"
        }
        info = "请顾客出示" + info_key + "付款码，将扫描枪对准进行扫描。(注：扫描枪分一维码/二维码以及光敏/纸质类型，请灵活选择)"
        $rootScope.scan("扫客户码支付", info, function(code){
          if(code.match(/^\d{7,18}$/) == null){
            $rootScope.alert("付款码格式不正确，请检查输入")
          }else{
            PayItemService.pay_by_seller_scan($scope.branch_id, $scope.order.id, pay_item.id, code, function(result){
              if(result.ok){
                $rootScope.alert("扫描成功, 请刷新查看支付状态")
                $scope.refresh_pay_item_state(pay_item)
              }else{
                $rootScope.alert(result.data)
              }
            })
          }
        })
      }

      $scope.refresh_pay_item_state = function(pay_item){
        PayItemService.get($scope.branch_id, $scope.order.id, pay_item.id, function(new_pay_item){
          pay_item.state = new_pay_item.state
          pay_item.state_name = new_pay_item.state_name
          if(new_pay_item.bill){ $scope.order.bill = new_pay_item.bill}
          check_order_paid()
        })
      }

      $scope.close_pay_item = function(pay_item){
        PayItemService.close($scope.branch_id, $scope.order.id, pay_item.id, function(new_pay_item){
          pay_item.state = new_pay_item.state
          pay_item.state_name = new_pay_item.state_name
        });
      }

      $scope.can_refund = function(pay_item){
        var match_pay_method = ["alipay", "alipay_offline"].indexOf(pay_item.name_sym) >= 0
        return pay_item.state == 'paid' && pay_item.pay_platform && match_pay_method;
      }

      $scope.refund = function(pay_item){
        if ($scope.can_refund(pay_item)) {
          $rootScope.auth_action('branch', 'order', 'refund', {branch_id: $scope.branch_id}, function () {
            $rootScope.confirm("确定要退款吗?", function(){
              PayItemService.refund($scope.branch_id, $scope.order.id, pay_item.id, function (new_pay_item) {
                pay_item.state = new_pay_item.state
                pay_item.state_name = new_pay_item.state_name
              });
            })
          })
        }
      }

      $scope.pay_item_qrcode_modal = {
        show: false,
        current_pay_item: null,
        hint: '',
        qr_code_url: '',
        clr_query_pay_item_state: null,
        show_extended_form: function(){
          ExtendedFormService.show_qrcode(this.hint, this.qr_code_url)
        },

        clr_busy_query_state: function(){
          if (this.clr_query_pay_item_state) {
            $interval.cancel(this.clr_query_pay_item_state)
            this.clr_query_pay_item_state = null;
          }
        },

        open:  function(){
          this.show_extended_form()
          this.show = true

          var This = this;

          this.clr_query_pay_item_state = $interval(function(){
            $scope.refresh_pay_item_state(This.current_pay_item)
            if (This.current_pay_item.state == 'paid'){
              This.close();
            }
          }, 2000);

          var clr_watch = $scope.$watch("pay_item_qrcode_modal.show", function(show){
            if (show == false){
              This.clr_busy_query_state()
              clr_watch()
            }
          });
          $scope.$on("$destroy", function(){
            This.clr_busy_query_state()
            clr_watch()
          });
        },
        refresh_qr_code: function(){
          PayItemService.get_pay_online($scope.branch_id, $scope.order.id, this.current_pay_item.id, false, function(result){
            if(result.qr_code_url){
              $scope.pay_item_qrcode_modal.qr_code_url = result.qr_code_url
              $scope.pay_item_qrcode_modal.show_extended_form()
            }
          })
        },
        replace_qr_code: function(){
          PayItemService.get_pay_online($scope.branch_id, $scope.order.id, this.current_pay_item.id, true, function(result){
            if(result.qr_code_url){
              $scope.pay_item_qrcode_modal.qr_code_url = result.qr_code_url
              $scope.pay_item_qrcode_modal.show_extended_form()
            }
          })
        },
        close: function(){
          this.show = false; ExtendedFormService.hide();
          this.clr_busy_query_state()
        },
        back: function(){
          this.close();
          $scope.refresh_pay_item_state(this.current_pay_item)
        }
      }

      $scope.moling = function(){
        BaseOrderService.moling($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
          // console.log(order.total)
          $scope.order = order;
        })
      }

      $scope.cancel_moling = function(callback){
        BaseOrderService.cancel_moling($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
          $scope.order = order;
          if(callback){callback()}
        })
      }

      // 右边折叠栏
      if($scope.order_type != "recharge"){
        $scope.active_menu_key = "hysb"
      }
      $scope.toggle_menu_key = function(key){
        if($scope.active_menu_key == key){
          $scope.active_menu_key = ""
        }else{
          if(key == "qxdz"){
            $scope.discount_modal.open(function(){
              $scope.active_menu_key = key
              $rootScope.focus('.qxdz input')
            })
          }else if(key == 'qxjm'){
            $scope.reduction_modal.open(function(){
              $scope.active_menu_key = key
              $rootScope.focus('.qxjm input')
            })
          }else if(key == 'qxmd'){
            if($scope.privilege_promotion()){
              alert_has_promotion()
            }else{
              $scope.active_menu_key = key
            }
          }else{
            if($scope.order_type == "recharge"){
              $rootScope.alert("不可用")
            }else{
              if(key == 'yhq'){
                $scope.active_menu_key = key
                $rootScope.focus('.yhq input')
              }else{
                $scope.active_menu_key = key
              }
            }
          }
        }
      }

      var unbind_right_menu_enter = $rootScope.bind_key('enter', function(){
        var active = ({
          yhq:  {modal: $scope.coupon_modal, action: 'search_coupon'},
          qxdz: {modal: $scope.discount_modal, action: 'submit'},
          qxjm: {modal: $scope.reduction_modal, action: 'submit'},
        })[$scope.active_menu_key]
        if(active){
          if($("."+$scope.active_menu_key+" input:focus").length>0){
            active.modal[active.action]();
          }
        }
      });

      // 快餐返回修改
      $scope.go_modify_fast_food = function(){
        if(is_order_paid()){
          $rootScope.alert("订单已经支付, 不能修改")
        }else{
          $rootScope.go("/branches/" + $scope.branch_id + "/fast_food?modify_order_id=" + $scope.order.id)
        }
      }

      $scope.is_fast_food = function(){
        return $scope.order && $scope.order.type_str == 'fastfood'
      }

      $scope.print_consume_bill = function(){
        PrintService.print_consume_bill($scope.order)
        TableService.check_out($rootScope.branch_id, $scope.order.table_id, {is_local_printed: $rootScope.local_printer_configed()}, function(resp){})
      }

      $scope.is_eat_in_hall = function(){
        return $scope.order && $scope.order.type_str == 'eat_in_hall'
      }

      var clear_watch_order = $scope.$watch("order", function(){
        if ($scope.order){
          switch ($scope.order.type_str){
            case 'eat_in_hall':
            {
              ExtendedFormService.show_order($scope.order.id);
              break;
            }
            case 'fastfood': {
              SetFastfoodExtendedForm({
                scope: $scope,
                model_name: 'order',
                reload: false
              });
              clear_watch_order();
              break;
            }
          }
        }
      }, true)

      $scope.$on("$destroy", function(){
        var path = $location.path();
        if (path.indexOf('/fast_food') == -1 && path.indexOf('/fastfood') == -1) {
          $rootScope.show_wechat_account_qrcode()
        }
      })

      // 辅助输入
      $scope.add_money_action = function(amount){}
      $scope.add_money = function(amount){ $scope.add_money_action(amount) }

      // 自动获取焦点
      function pay_method_filter_input_focus(){
        $rootScope.focus(".pay-method-filter-key input")
      }
      pay_method_filter_input_focus()


      var can_trigger = true;
      var search_pay_method_select = function(e){
        var filter = $(".pay-method-filter-key input:focus");
        var focus_input_length = filter.length
        if(focus_input_length > 0 && filter.val()=='' && !can_trigger){return;}
        if(focus_input_length > 0 && e.keyCode == 13){
          if(can_trigger&&filter.val()==''){
            // 搜索框无输入只允许触发一次
            can_trigger = false;
          }
          var ins = $scope.show_builtin_pay_methods()
          var cus = $scope.show_custom_pay_methods()
          var pay_method = ins[0] || cus[0]
          if(pay_method){
            $scope.select_pay_method(pay_method)
          }
        }
      }
      $(document).on("keydown", search_pay_method_select)
      $scope.$on("$destroy", function(){
        $(document).off("keydown", search_pay_method_select)
      })

      var pay_item_confirm = function(e){
        var focus_input_length = $(".pay-item-modal input:focus").length
        if(focus_input_length > 0){
          if(e.keyCode == 13){
            // 回车
            if($scope.pay_item_modal.can_submit()){
              $scope.pay_item_modal.submit()
              $scope.pay_method_filter_key = ""
              pay_method_filter_input_focus()
            }
          }else{
            // 自动清除金额
            var code = e.keyCode
            if(!$scope.pay_item_modal.changed){
              $scope.pay_item_modal.changed = true
              // 0 - 9
              if(code >= 48 && code <= 57){
                $scope.pay_item_modal.pay_item.amount = code - 48
              }else if(code >= 96 && code <= 105){
                $scope.pay_item_modal.pay_item.amount = code - 96
              }
            }
          }
        }
      }
      $(document).on("keydown", pay_item_confirm)
      $scope.$on("$destroy", function(){ $(document).off("keydown", pay_item_confirm)})


      // credits_deduction
      $scope.is_normal_user = function(){ return $scope.order && $scope.order.vip_info && $scope.order.vip_info.is_default }
      $scope.can_credits_deduction = function(){ return $rootScope.can("branch", "order", "settle") && ($scope.is_vip() || $scope.is_normal_user()) && !$scope.order.credits_deduction }
      $scope.can_cancel_credits_deduction = function(){ return $rootScope.can("branch", "order", "settle") && ($scope.is_vip() || $scope.is_normal_user()) && $scope.order.credits_deduction }
      $scope.credits_deduction_modal = {
        show: false,
        credits: 0,
        submit: function(){
          if($scope.credits_deduction_modal.can_submit()){
            BaseOrderService.credits_deduction($scope.order_type, $scope.branch_id, $scope.order.id, $scope.credits_deduction_modal.credits, function(order){
              $scope.credits_deduction_modal.toggle_show()
              $scope.credits_deduction_modal.credits = 0
              $scope.order = order
              $rootScope.alert("积分抵扣成功")
            })
          }
        },
        can_submit: function(){
          if(!$scope.can_credits_deduction()){return false;}
          var credits = parseInt($scope.credits_deduction_modal.credits)
          return  credits > 0 && credits <= $scope.order.vip_info.credits_wallet
        },
        toggle_show: function(){ $scope.credits_deduction_modal.show = !$scope.credits_deduction_modal.show }
      }
      $scope.cancel_credits_deduction = function(){
        $rootScope.confirm("确定取消积分抵扣", function(){
          BaseOrderService.cancel_credits_deduction($scope.order_type, $scope.branch_id, $scope.order.id, function(order){
            $scope.order = order
            $rootScope.alert("取消积分抵扣成功")
          })
        })
      }

      /* 折扣方案 */
      $scope.discount_plan = SetDiscountPlanAction.init(function(){
        return $scope.order;
      });
      $scope.discount_plan.order_changed = function(new_order){
        $scope.order = new_order;
      }


      $scope.key_of_hysb = HotkeyService.get_key('hysb');
      $scope.key_of_yhq  = HotkeyService.get_key('yhq');
      $scope.key_of_qxdz = HotkeyService.get_key('qxdz');
      $scope.key_of_qxjm = HotkeyService.get_key('qxjm');
      $scope.key_of_moling = HotkeyService.get_key('moling');
      $scope.key_of_print_consume_bill = HotkeyService.get_key('print_consume_bill');

      var unbind_hotkey_hysb = $rootScope.bind_key($scope.key_of_hysb, function(){$scope.toggle_menu_key('hysb')})
      var unbind_hotkey_yhq  = $rootScope.bind_key($scope.key_of_yhq, function() {$scope.toggle_menu_key('yhq')})
      var unbind_hotkey_qxdz = $rootScope.bind_key($scope.key_of_qxdz, function(){$scope.toggle_menu_key('qxdz')})
      var unbind_hotkey_qxjm = $rootScope.bind_key($scope.key_of_qxjm, function(){$scope.toggle_menu_key('qxjm')})
      var unbind_hotkey_moling = $rootScope.bind_key($scope.key_of_moling, $scope.moling)
      var unbind_hotkey_print_consume_bill = $rootScope.bind_key($scope.key_of_print_consume_bill, $scope.print_consume_bill)

      $scope.$on("$destroy", function(){
        $scope.discount_plan.destroy();
        clear_watch_discount_percent()
        clear_watch_discount()
        clear_watch_disable_discount_amount()
        clear_watch_reduce_amount()
        clear_watch_order_total()
        clear_watch_paid_amount()
        clear_watch_paid_amount2()
        clear_watch_order()
        unbind_right_menu_enter()
        unbind_hotkey_hysb()
        unbind_hotkey_yhq()
        unbind_hotkey_qxdz()
        unbind_hotkey_qxjm()
        unbind_hotkey_moling()
        unbind_hotkey_print_consume_bill()
      })

      $scope.remove_promotion_adjustment = function(ad){
        $rootScope.confirm("确认取消该优惠?", function(){
          BaseOrderService.add_disabled_promotion($scope.order_type, $scope.branch_id, $scope.order_id, ad.promotion_id, function(order){
            $scope.order = order
          })
        })
      }

      $scope.recover_promotion_adjustment = function(dp){
        $rootScope.confirm("确认恢复该优惠?", function(){
          BaseOrderService.remove_disabled_promotion($scope.order_type, $scope.branch_id, $scope.order_id, dp.id, function(order){
            $scope.order = order
          })
        })
      }

    }])
