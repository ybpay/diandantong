angular.module('webpos', WebposModules.get([
  'ngRoute','ngResource', 'ngCookies', 'errorReporter',
  'webpos.route_config',
  'webpos.interceptor',
  'webpos.constants',
  'ngDraggable', 'ngKeypad'
])).config(['$httpProvider', 'InterceptorProvider',
  function($httpProvider, InterceptorProvider){
    $httpProvider.defaults.useXDomain = true;
    var all_interceptors = InterceptorProvider.$get().get()
    angular.forEach(all_interceptors, function(interceptor){
      $httpProvider.interceptors.push(interceptor);
    })
}]).config(['$routeProvider','RouteConfigProvider',
  function($routeProvider, RouteConfigProvider){
    var all_configs = RouteConfigProvider.$get().get()
    angular.forEach(all_configs, function(conf){
       $routeProvider.when(conf.path, {
         //templateUrl: conf.templateUrl + version_timestamp,
         templateUrl: conf.templateUrl,
         controller: conf.controller,
         feature: conf.feature
       })
    })
    $routeProvider.otherwise({
      redirectTo: '/'
    });
}]).run([ '$http','$location','$rootScope','$route','$timeout','$cacheFactory','$interval', 'TemplateService', 'AccountService','RouteConfig',
  'NotifyService','NotificationService','VerifyVipInfoService','Branch','WirePrinterService','TitleScrollService',
  'ExtendedFormService','PhoneBoxService','RefreshService','TtsService','QueueFormService', 'EstimateClearService',
  'GiftReasonService','AuthorizationService','PermissionService', 'BrowserFormService', 'Box', 'PrintService', "LocalStorageCache",
  function($http,$location , $rootScope , $route, $timeout, $cacheFactory, $interval, TemplateService, AccountService, RouteConfig,
           NotifyService, NotificationService,VerifyVipInfoService, Branch , WirePrinterService,
           TitleScrollService,ExtendedFormService,PhoneBoxService,RefreshService, TtsService, QueueFormService, EstimateClearService,
           GiftReasonService,AuthorizationService,PermissionService, BrowserFormService, Box, PrintService,LocalStorageCache){
    $rootScope.after_settle_url = null;
    if(!$rootScope.terminal_id){
      $rootScope.terminal_id = "rs" + Date.parse(new Date());
    }
    $rootScope.is_self_message = function(msg){ return msg.terminal_id == $rootScope.terminal_id}
    $rootScope.is_not_self_message = function(msg){ return msg.terminal_id != $rootScope.terminal_id}
    $rootScope.go = function(url){
      if(url.match(/\/settle/) && $location.path().indexOf("settle") == -1){
        $rootScope.after_settle_url =  $location.path()
      }
      $location.url(url)
    }
    $rootScope.go_path = function(path){
      window.location.href = window.location.origin + path
    }
    $rootScope.back = function(){
      if(!$rootScope.isLoading()){
        clearLoadingMask();
        window.history.back();
      }
    }
    $rootScope.isLoading = function () {
       return $http.pendingRequests.length !== 0;
    };
    $rootScope.reload = function(bool){ if(bool){ location.reload() }else{ $route.reload()}}
    $rootScope.sign_out = function(){
      $rootScope.confirm("确定退出?", function(){
        AccountService.sign_out()
      })
    }
    $rootScope.partial = function(partial_name){
      return "/webpos/partials/" + partial_name + ".html";
    }
    $rootScope.go_branch = function(branch, order_type){
      var url = ""
      if(branch.is_abstract){
        $rootScope.go("/")
        return
      }
      if($rootScope.is_boss()){
        url = '/branches/' + branch.id+'/' + (order_type||'eat_in_hall')
      }else if ($rootScope.is_queue_waiter()) {
        url = '/branches/' + branch.id+'/guest_queues'
      }else{
        url = '/branches/' + branch.id+'/' + (order_type||'eat_in_hall')
      }
      if($location.path() == url){
        $rootScope.reload()
      }else{
        $rootScope.go(url)
      }
    }
    $rootScope.set_table_css = function(table_color){
      if(table_color){
        $('#table_css').html(".wp-table-btn.idle {    background-color: "+table_color.idle_color+";} \
          .wp-table-btn.opened {    background-color: "+table_color.opened_color+";} \
          .wp-table-btn.ordered{    background-color: "+table_color.ordered_color+";} \
          .wp-table-btn.check_outing{    background-color: "+table_color.check_outing_color+";} \
          .wp-table-btn.paid{    background-color: "+table_color.paid_color+";} \
          ");
        }
    }
    //设置系统时间
    function set_sys_time(){
      var system_time = $('meta[name="system_time"]').attr("content")
      if (Math.abs(system_time - Date.now() > 300000)) {
        $rootScope.alert("提示: 服务器时间和您客户端本地时间相差超过5分钟,请手动校正客户端本地时间（注：显示时间以本地时间为准）")
      };
      var refresh_time = function(){
        $rootScope.system_time = Date.now()
      }
      $interval(refresh_time,1000)
    };




    $rootScope.base_url = function(){ 
      if(!$rootScope.shop){
        console.error('base_url do not have shop.slug')
        return ''
      }
      return "/webpos/shops/" + $rootScope.shop.slug 
    }
    $rootScope.set_shop = function(shop){
      $rootScope.shop = shop
      $rootScope.show_wechat_account_qrcode()
      $rootScope.set_table_css(shop.table_color)
    }

    $rootScope.time_since_from = function(timestamp){
      var now = new Date()
      var total_seconds = Math.floor(((now - Date.parse(timestamp)) / 1000))
      var minutes = Math.floor(total_seconds / 60)
      return minutes;
    }
    $rootScope.set_branch = function(branch){
      $rootScope.branch = branch
      $rootScope.branch_id = (branch ? branch.id : null)
    }
    $rootScope.go_notification = function(){
      if($rootScope.branch){
        $rootScope.go("/branches/" + $rootScope.branch_id + "/notification")
      }
    }
    $rootScope.show_wechat_account_qrcode = function(){
      if($rootScope.shop && $rootScope.shop.wechat_account_gonghao_open_id){
        ExtendedFormService.show_wechat_account_qrcode($rootScope.shop.wechat_account_gonghao_open_id)
      }else{
        ExtendedFormService.hide()
      }
    }
    // 权限验证
    $rootScope.auth_action = AuthorizationService.auth_action;
    $rootScope.current_authorizer_id = AuthorizationService.current_authorizer_id;
    $rootScope.clear_authorizer = AuthorizationService.clear_authorizer;

    // 客显
    $rootScope.show_cef_form = function(form_name){
      if(form_name == 'queue'){
        QueueFormService.set_queue_form_enable(true)
        ExtendedFormService.set_extended_form_enable(false)
        QueueFormService.show()
      }else if(form_name == 'extended'){
        QueueFormService.set_queue_form_enable(false)
        ExtendedFormService.set_extended_form_enable(true)

        ExtendedFormService.show(true)
        $rootScope.show_wechat_account_qrcode()
      } else if (form_name == "fastfood") {
        QueueFormService.set_queue_form_enable(false)
        ExtendedFormService.set_extended_form_enable(true)
        ExtendedFormService.show(true)
      }
    }
    $rootScope.show_cef_form('extended')

    AccountService.get(function(account){
      $rootScope.account = account
      $rootScope.set_shop(account.shop)
      NotifyService.restart()
      $rootScope.has_multi_branches = account && account.branches && account.branches.length > 1
    })

    $rootScope.can = PermissionService.can;
    $rootScope.is_boss        = function(){ return AccountService.is_role("boss") }
    $rootScope.is_worker      = function(){ return AccountService.is_role("worker") }
    $rootScope.is_deliveryman = function(){ return AccountService.is_role("deliveryman") }
    $rootScope.is_cook        = function(){ return AccountService.is_role("cook") }
    $rootScope.is_chef        = function(){ return AccountService.is_role("chef") }
    $rootScope.is_waiter      = function(){ return AccountService.is_role("waiter") }
    $rootScope.is_cashier     = function(){ return AccountService.is_role("cashier") }
    $rootScope.is_queue_waiter = function(){return AccountService.is_role("queue_waiter")}

    $rootScope.is_controller = function(names){ return angular.isArray(names) ? (names.indexOf($route.current.controller) != -1) : (names === $route.current.controller) }

    // 用来记录最近在本终端埋单的订单号，如果收到订单支付消息，且在这个列表中没有记录，就会弹出提示
    // TODO: 以后可在服务器端记录收银终端，准确下发要提示的订单支付方式
    $rootScope.settled_orders_cache = new Cache();
    NotificationService.start();
    $rootScope.notification_length = function(){ return NotificationService.length($rootScope.branch_id) }

    $rootScope.lock_confirm_modal = Box.lock_confirm_modal;
    $rootScope.confirm = Box.confirm;
    $rootScope.alert = Box.alert;

    set_sys_time()  // set_sys_time 依赖 $rootScope.alert()

    $rootScope.env = WebposConst.env
    // 是否为内嵌chromium
    $rootScope.is_cef = WirePrinterService.has_object()
    $rootScope.enable_jvk = LocalStorageCache.get("enable_jvk") || $rootScope.is_cef
    $rootScope.toggle_jvk = function(){
      $rootScope.enable_jvk = !$rootScope.enable_jvk;
      LocalStorageCache.set("enable_jvk", $rootScope.enable_jvk)
    }
    // 提交状态
    $rootScope.is_submiting = false
    // 消息声音播放开关
    $rootScope.enable_play_sound = false
    // 排号引导自动播放开关
    $rootScope.enable_auto_play_queue_guide_sound = false

    $rootScope.toggle_play_sound = function(){ $rootScope.enable_play_sound = !$rootScope.enable_play_sound }

    $rootScope.$on('event:loginRequired', function(){
      $rootScope.account = null;
      AccountService.destroy_ability();
      // $location.path(WebposConst.login_path);
      $rootScope.clear_cache()
      NotifyService.clear()
      PermissionService.destroy();
      $rootScope.go(WebposConst.login_path)
    });

    $rootScope.$on('$routeChangeStart', function(event, next, current) {

        var path = $location.path()
        var feature = next.feature
        var branch_id = next.params.branch_id
        var np = next.originalPath
        var all_configs = RouteConfig.get()
          if(!$rootScope.features ||$rootScope.has_feature(feature)){
               if(np == "/branches/:branch_id/bill_center"){
                  $rootScope.go_path("/webpos/bill#/shop/branches/"+next.params.branch_id+"/bill")
                  event.preventDefault();
                }else if(np == "/branches/:branch_id/estimate_clear"){
                  console.log("enter estimate")
                  $rootScope.go_path("/webpos/estimate#/shop/branches/"+next.params.branch_id+"/estimate")
                  event.preventDefault();
                }else if(np == "/branches/:branch_id/guest_queues"){
                  $rootScope.go_path("/webpos/queue#/shop/branches/"+next.params.branch_id+"/queue")
                  event.preventDefault();
                }else if(np == "/branches/:branch_id/vip_infos"){
                  $rootScope.go_path("/webpos/users#/shop/branches/"+next.params.branch_id+"/users")
                  event.preventDefault();
                }else{
                  if(path.indexOf("guest_queues") != -1){
                    $rootScope.show_cef_form('queue')
                  } else if (path.indexOf("fastfood") != -1 || path.indexOf("fast_food") != -1){

                  } else {
                    $rootScope.show_cef_form('extended')
                  }
                }
          }else{
            if (typeof(branch_id) == "undefined") {
              $rootScope.go_path("/webpos#/")
            }else{
              event.preventDefault();
           }
        }
    });

    $rootScope.pay_methods = [
        { value: 'pay_on_face'       , label: '现金结账' }    ,
        { value: 'vip_card_pay'      , label: '会员卡支付' }   ,
        { value: 'bank_card_pay'     , label: '银行卡支付' }   ,
        { value: 'wechatpay_offline' , label: '线下微信支付' }  ,
        { value: 'alipay_offline'    , label: '线下支付宝支付' }
      ]

    // cache
    $rootScope.webpos_cache = $cacheFactory("webpos");
    $rootScope.get_cache = function(key){
      return $cacheFactory.get('webpos').get(key);
    }
    $rootScope.set_cache = function(key, value){
      $cacheFactory.get('webpos').put(key, value);
    }
    $rootScope.clear_cache = function(){
      $cacheFactory.get('$http').removeAll();
      $cacheFactory.get('webpos').removeAll();
    }

    // 开班
    $rootScope.open_shift_modal = {
      show: false,
      prompt: false,
      pre_cash_amount: null,
      can_open: function(){
        return $rootScope.branch && !$rootScope.branch.on_shift
      },
      open: function(){
        if(this.can_open()){
          if($rootScope.branch.open_shift_num > 0){
           this.open_shift_num = $rootScope.branch.open_shift_num
           this.prompt = true
          }else{
           this.pre_cash_amount = null
           this.show = true
          }
        }else{
          $rootScope.alert("该门店已经开班")
        }
      },
      submit: function(){
        Branch.open_shift({id:$rootScope.branch_id}, {pre_cash_amount: this.pre_cash_amount}).$promise.then(function(branch){
          $rootScope.clear_cache()
          $rootScope.branch = branch
          $rootScope.open_shift_modal.close()
          $rootScope.reload()
        })
      },
      close: function(){
        this.show = false
        this.prompt = false
      },
      ok: function(){
        this.pre_cash_amount = null
        this.show = true
      }
    }

    // 交班
    $rootScope.close_shift_modal = {
      show: false,
      shift: null,
      can_open: function(){
        return $rootScope.branch && $rootScope.branch.on_shift && $rootScope.account && ($rootScope.branch.shift_account_id == $rootScope.account.id || $rootScope.is_boss() )
      },
      open: function(){
        if(this.can_open()){
          Branch.get_shift({id: $rootScope.branch_id}).$promise.then(function(shift){
            $rootScope.close_shift_modal.shift = shift
            var pth = shift.print_text
            pth = pth.replace(/\n/m, "<br>")
            pth = pth.replace(/\s/m, "&nbsp;")
            pth = pth.replace(/<M>/m,   "<span class='bill-m'>")
            pth = pth.replace(/<\/M>/m, "</span>")
            pth = pth.replace(/<B>/m,   "<span class='bill-b'>")
            pth = pth.replace(/<\/B>/m, "</span>")
            pth = pth.replace(/<C>/m,   "<span class='bill-c'>")
            pth = pth.replace(/<\/C>/m, "</span>")
            pth = pth.replace(/<CM>/m,  "<span class='bill-cm'>")
            pth = pth.replace(/<\/CM>/m,"</span>")
            pth = pth.replace(/<CB>/m,  "<span class='bill-cb'>")
            pth = pth.replace(/<\/CB>/m,"</span>")
            $rootScope.close_shift_modal.shift.print_text_html = pth
            var pth = shift.recharge_print_text
            pth = pth.replace(/\n/m, "<br>")
            pth = pth.replace(/\s/m, "&nbsp;")
            pth = pth.replace(/<M>/m,   "<span class='bill-m'>")
            pth = pth.replace(/<\/M>/m, "</span>")
            pth = pth.replace(/<B>/m,   "<span class='bill-b'>")
            pth = pth.replace(/<\/B>/m, "</span>")
            pth = pth.replace(/<C>/m,   "<span class='bill-c'>")
            pth = pth.replace(/<\/C>/m, "</span>")
            pth = pth.replace(/<CM>/m,  "<span class='bill-cm'>")
            pth = pth.replace(/<\/CM>/m,"</span>")
            pth = pth.replace(/<CB>/m,  "<span class='bill-cb'>")
            pth = pth.replace(/<\/CB>/m,"</span>")
            $rootScope.close_shift_modal.shift.recharge_print_text_html = pth
            $rootScope.close_shift_modal.shift.current_time = new Date()
            $rootScope.close_shift_modal.show = true;
          })
        }else{
          if($rootScope.branch){
            if(!$rootScope.branch.on_shift){
              $rootScope.alert("该门店尚未开班")
            }else{
              if($rootScope.account && $rootScope.branch.shift_account_id != $rootScope.account.id){
                open_shift_account_name = $rootScope.branch.shift_account_name
                $rootScope.alert("开班人员为:"+open_shift_account_name+" , 您不是该门店当前班次的开班人员, 不能交班")
              }
            }
          }
        }
      },
      can_submit: function(){
        if ($rootScope.close_shift_modal.shift == null) {
          return false
        };
        return $rootScope.close_shift_modal.shift.active_orders_count == 0
        //return true;
      },
      close: function(){
        $rootScope.close_shift_modal.show = false;
      },

      do_close_shift: function(){
        var This = this;
        Branch.close_shift({id: $rootScope.branch_id}, {}).$promise.then(function(branch){
          $rootScope.close_shift_modal.close()
          $rootScope.clear_cache()
          $rootScope.branch = branch
          $rootScope.confirm("交班成功, 是否打印交班记录?", function(){
            $rootScope.close_shift_modal.print()
            $rootScope.sign_out()
          }, "是", function(){
            $rootScope.sign_out()
          }, "否")
        })
      },

      submit: function(){
        var This = this;
        if($rootScope.close_shift_modal.can_submit()){
          $rootScope.confirm("确认交班?", function(){
            This.do_close_shift();
          })
        }else{
          $rootScope.confirm("还有"+$rootScope.close_shift_modal.shift.active_orders_count+"个订单未完全处理, 确定交班吗？", function(){
            This.do_close_shift();
          })
        }
      },
      print: function(){
        if($rootScope.local_printer_configed()){
          WirePrinterService.print($rootScope.close_shift_modal.shift.print_text, 1)
        }else{
          Branch.print_shift({id: $rootScope.branch_id}, {shift_id: $rootScope.close_shift_modal.shift.id, bill_type: "base"}).$promise.then(function(){
          })
        }
      },
      print_recharge: function(){
        if($rootScope.local_printer_configed()){
          WirePrinterService.print($rootScope.close_shift_modal.shift.recharge_print_text, 1)
        }else{
          Branch.print_shift({id: $rootScope.branch_id}, {shift_id: $rootScope.close_shift_modal.shift.id, bill_type: "recharge"}).$promise.then(function(){
          })
        }
      },

      sdu_upload_orders: function(){
        Branch.sdu_upload_orders({id: $rootScope.branch_id}, {}).$promise.then(function(){
          $rootScope.alert("已提交至上传队列")
        })
      },

      sdu_query_orders: function(){
        Branch.sdu_query_orders({id: $rootScope.branch_id}, {}).$promise.then(function(resp){
          $rootScope.alert("已上传"+resp.uploaded+", 待上传"+resp.pending+",已取消"+resp.canceled+",未上传"+resp.not_find)
        })
      }
    }

    $(window).focus(function () {
        TitleScrollService.cancel()
    });

    $rootScope.local_printer_configed = function(){
      if(!$rootScope.is_cef){return false;}
      return WirePrinterService.is_config();
    }

    $rootScope.need_config_local_printer = function(){
      if(!$rootScope.is_cef){return false;}
      return !WirePrinterService.is_config();
    }

    // 配置提醒消息
    // alert_message: {label: "xxx", click_fn: function(){}}
    $rootScope.alert_messages = [];

    $rootScope.click_alert_message = function(alert_message){
      $rootScope.confirm(alert_message.label,
        function(){
          alert_message.click_fn();
          $rootScope.hide_alert_message(alert_message);
        }, '处理',
        function(){
          $rootScope.hide_alert_message(alert_message);
        }, '忽略'
      );
      return false;
    }

    $rootScope.hide_alert_message = function(alert_message){
       var idx = $rootScope.alert_messages.indexOf(alert_message)
       $rootScope.alert_messages.splice(idx, 1);
    }

    if($rootScope.need_config_local_printer()){
      $rootScope.alert_messages.push({
        label: "当前打印机没有配置, 点击  >>这里<<  进行配置",
        click_fn: function(){
          $rootScope.active_printer_config = true
          $rootScope.go("/settings")
        }
      })
    }

    $rootScope.queue_bill_type = function(){
      return $rootScope.is_cef ? WirePrinterService.get_printer_width() : ""
    }

    $rootScope.order_bill_type = function(){
      return $rootScope.is_cef ? WirePrinterService.get_order_bill_type() : null;
    }

    $rootScope.wire_print_order_bill = function(order){
      PrintService.print_order_bill(order)
    }

    $rootScope.local_print_order_bill = function(bill, is_print_one_time){
      WirePrinterService.is_manual_print().then(function(result){
        if (!result) {
          PrintService.print_order_bill_local(bill, is_print_one_time)
        }
      });
    }

    $rootScope.local_print_queue_bill = function(bill){
      PrintService.print_queue_bill_local(bill)
    }

    // 扫码
    $rootScope.scan = function(title, info, success_callback, action_name, action_callback){
      $("input").blur()
      $rootScope.scan_modal.code = ""
      $rootScope.scan_modal.title = title
      $rootScope.scan_modal.info = info
      $rootScope.scan_modal.success_callback = success_callback
      $rootScope.scan_modal.action_name = action_name
      $rootScope.scan_modal.action_callback = action_callback
      $rootScope.scan_modal.open()
      $timeout(function(){
        ExtendedFormService.show_hint(info)
      }, 500)
    }

    $rootScope.scan_modal = {
      show: false,
      show_input: false,
      code: "",
      title: "",
      info: "",
      action_name: "",
      success: function(){
        this.close()
        if(this.success_callback){ this.success_callback(this.code)}
      },
      success_callback: function(){},
      action: function(){
        this.close()
        if(this.action_callback){ this.action_callback()}
      },
      action_callback: function(){},
      add_code: function(c){ this.code += c;},
      toggle_input: function(){
        this.show_input = !this.show_input
        if(this.show_input){
          $rootScope.focus(".scan-modal-code input")
        }
      },
      open: function(){
        this.show = true;
        this.show_input = false;
        this.code = "";
        $rootScope.focus(".scan-modal-code input")
      },
      close: function(){ this.show = false; },
    }

    //获取输入焦点
    $rootScope.focus  = function(selector){ $rootScope.dom_op(selector, 'focus')}
    $rootScope.select = function(selector){ $rootScope.dom_op(selector, 'select')}
    $rootScope.dom_op = function(selector, fn_name){
      setTimeout(function() {
        var dom = $(selector)[0];
        if(dom){
          dom[fn_name]()
        }else {
          console.error("unable to do " + fn_name + "as dom is not exists")
        }
      }, 700);
    }



    $(document).on("keydown", function(e){
      if($rootScope.scan_modal.show){
        // 扫码
        var tag = $(e.target)[0].localName
        var code = e.keyCode
        var ENTER = 13,
            ZERO  = 48,
            NINE  = 57,
            NUMPAD_ZERO = 96,
            NUMPAD_NINE = 105,
            DC1 = 17, // Device Control 1 (oft. XON) [ Left Control ]
            J = 74;
        if(code == ENTER){
          $rootScope.scan_modal.success();
        }else if(tag != "input" && code >= ZERO && code <= NINE){
          $rootScope.scan_modal.add_code(code - ZERO);
        }else if(tag != "input" && code >= NUMPAD_ZERO && code <= NUMPAD_NINE){
          $rootScope.scan_modal.add_code(code - NUMPAD_ZERO)
        }else if(code == DC1 || code == J){
          // 扫描枪在enter 之后又加了 Ctrl + j, 在chrome下是打开下载的快捷键，屏蔽这个组合键
          e.preventDefault();
        }
        $rootScope.$apply();
      }else{
        var top_modal_key = ({
          13: 'enter',
          27: 'esc',
        })[e.keyCode]
        if(top_modal_key){
          //priority3: hotkeys of confirm_modal
          //priority2: hotkeys of normal_modal
          //priority1: hotkeys of base
          hotkey_p3.trigger(e) && hotkey_p2.trigger(e) && hotkey_p1.trigger(e)
        }else{
          hotkey_p2.trigger(e) && hotkey_p1.trigger(e)
        }
      }
    })

    // 热键
    $rootScope.bind_key = function(key, action){
      var desc = {key: key, action: action}
      return hotkey_p1.bind(desc)
    }

    hotkey_p1.bind({
      key: 'esc',
      action: function(){
        $timeout(function(){
          $rootScope.back()
        }, 0)
      }
    })


    // 赠菜理由
    $rootScope.gift_reasons_modal = {
      show:false,
      gift_reasons: [],
      active_gift_reason: "",
      callback: undefined,
      open: function(callback){
        GiftReasonService.query(function(gift_reasons){
          $rootScope.gift_reasons_modal.gift_reasons = gift_reasons
        })
        this.callback = callback
        this.show = true
      },
      close: function(){ this.show = false },
      can_submit: function(){
        return this.active_gift_reason;
      },
      submit: function(){
        if(this.callback){ this.callback(this.active_gift_reason)}
        this.close()
      },
      select: function(gift_reason){
        this.active_gift_reason = gift_reason.name
      }
    }

    // 改重量
    $rootScope.change_weight_modal = {
      show: false,
      callback: undefined,
      itemable: null,
      weight: null,
      open: function(itemable, callback){
        // console.log(itemable)
        this.itemable = itemable;
        this.weight = itemable.weight;
        this.callback = callback;
        this.show = true;
        $rootScope.select('.change-weight input')
      },
      close: function(){this.show = false},
      submit: function(){
        if(this.callback){
          this.callback(this.itemable, this.weight);
        }
        this.close();
      }
    }

    // 会员扫码识别
    $rootScope.vip_scan_verify = function(title, hint, success, enable_reload, only_vip){
      $rootScope.vip_scan_modal.title = title
      $rootScope.vip_scan_modal.hint = hint
      $rootScope.vip_scan_modal.enable_reload = enable_reload
      $rootScope.vip_scan_modal.scan_success = false
      $rootScope.vip_scan_modal.only_vip = only_vip
      $rootScope.vip_scan_modal.open()
      VerifyVipInfoService.verify(function(qrcode_url){
        $rootScope.vip_scan_modal.qrcode_url = qrcode_url
        ExtendedFormService.show_qrcode(hint, qrcode_url)
      }, function(vip_info){
        success(vip_info)
        $rootScope.vip_scan_modal.close();
      }, function(){
        $rootScope.vip_scan_modal.scan_success = true
      }, only_vip)
    }
    $rootScope.vip_scan_modal = {
      show: false,
      title: "",
      hint: "",
      qrcode_url: null,
      enable_reload: false,
      scan_success: false,
      only_vip: false,
      open: function(){ this.show = true },
      close: function(){
        this.show = false
        NotifyService.remove_message_handler("VERIFY_VIPINFO")
        NotifyService.remove_message_handler("VERIFY_VIPINFO_SCAN_SUCCESS")
      },
      reload_qrcode: function(){
        VerifyVipInfoService.reload_qrcode(function(qrcode){
          $rootScope.vip_scan_modal.qrcode_url = qrcode.url
        }, this.only_vip)
      }
    }

    // 来电弹窗
    if($rootScope.is_cef){
      PhoneBoxService.caller(function(number){
        if($rootScope.branch){
          $rootScope.confirm("呼入电话: "+ number + "，请选择顾客服务类型：", function(){
            $rootScope.go("/branches/" + $rootScope.branch_id + "/delivery?caller_number=" + number)
          }, "外卖", function(){
            $rootScope.go("/branches/" + $rootScope.branch_id + "/reservation?caller_number=" + number)
          }, "预订")
          $rootScope.$apply();
        }
      })
    }

    // 语音自动播放
    $rootScope.enable_auto_voice = get_ddb_cache("enable_auto_voice")
    $rootScope.last_order_settle_time = new Date()
    $rootScope.auto_voice_interval_time = 1000 * 60 * 0.5 ;
    $rootScope.after_wait = false;

    RefreshService.add($rootScope, function(){
      var now = new Date()
      if($rootScope.enable_auto_voice && now - $rootScope.last_order_settle_time > $rootScope.auto_voice_interval_time){
        $rootScope.after_wait = true;
      }
    }, $rootScope.auto_voice_interval_time)
    $rootScope.set_last_order_settle_time = function(){
      $rootScope.last_order_settle_time = new Date()
    }
    $rootScope.set_enable_auto_voice = function(bool){
      $rootScope.enable_auto_voice = bool
      set_ddb_cache("enable_auto_voice", bool)
    }
    $rootScope.play_subscribe_voice = function(){
      if($rootScope.after_wait){
        TtsService.play("亲爱的顾客，为了更加方便您的用餐，您可以使用微信扫一扫功能，关注本店公众号 "+ $rootScope.shop.wechat_account_name +" 进行手机自助下单，本公众号支持“微信预定”，“微信堂点”，“微信外卖” 以及 “微信排队”等多种玩法，欢迎大家体验。", 1)
        $rootScope.after_wait = false;
      }
    }

    NotifyService.set_message_handler('ESTIMATE_CLEAR', function(msg){
      if(msg.notify_self || !$rootScope.is_self_message(msg)){
        $rootScope.$emit("event:estimate_clear", msg)
      }
    });

    $rootScope.enable_waiter_message = get_ddb_cache("enable_waiter_message")
    $rootScope.set_enable_waiter_message = function(bool){
      $rootScope.enable_waiter_message = bool
      set_ddb_cache("enable_waiter_message", bool)
    }
    NotifyService.set_message_handler('CALL_WAITER_MESSAGE', function(msg){
      var now = new Date();
      var t = now.getTime() / 1000 - parseInt(msg.created_at);
      if($rootScope.enable_waiter_message && t < 5*60){
        $rootScope.alert(msg.content, 1000 * 60)
      }
    });

    NotifyService.set_message_handler('NEW_DISTANCE_LIMITED_ORDER', function(msg){
      $rootScope.alert(msg.content + " 有新单因距离限制需要手动确认", 1000*60)
    });

    //判断角色是否可以设置服务员选项,复用
    $rootScope.can_trace_waiter = function(){
      return $rootScope.can("branch", "eat_in_hall_order", "trace_waiter")
    }

    // 弹钱箱
    $rootScope.open_cashbox = function(){
      if($rootScope.is_cef && $rootScope.local_printer_configed()){
        WirePrinterService.open_cashbox()
      }else{
        $rootScope.alert("对不起，无法弹出钱箱。您没有配置本地打印机或者您使用的不是收银系统客户端软件，也可能是您的使用的收银系统客户端不是最新版本")
      }
    }

    // ============================================================
    // 用在单机模式切换回在线模式时,修改颜色和标题
    // ============================================================
    if (BrowserFormService.has_object()){
      if (BrowserFormService.set_color) {
        BrowserFormService.set_color("#ff7f50");
      }

      if (BrowserFormService.get_title && BrowserFormService.set_title) {
        BrowserFormService.get_title().then(function (title) {
          var offline_title = '(单机模式)'
          if (title.indexOf(offline_title) != -1) {
            title = title.replace(offline_title, '')
            BrowserFormService.set_title(title)
          }
        });
      }
    }

  }]);




