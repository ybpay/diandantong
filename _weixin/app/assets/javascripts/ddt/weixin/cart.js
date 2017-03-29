angular.module('ddt_cart', Ddt.buildAppDependencies(
  [
    'ddt_app.route_config.cart',
  ]
.concat(Base.requires)))
.config(Base.config.interceptors)
.config(Base.config.routes)
.config(Base.config.location)
.run(['$location', '$route', '$rootScope', '$timeout', '$routeParams','ShopService', 'UserService', 'DdtConst', 'UrlHelperService', 'HistoryUrlService', 'WechatShareRecordService',
  function($location, $route, $rootScope, $timeout, $routeParams, ShopService, UserService, DdtConst, UrlHelperService, HistoryUrlService, WechatShareRecordService){

    $rootScope.hide_menu_default = true;
    $rootScope = Base.init($rootScope, $route, $location, DdtConst, HistoryUrlService, WechatShareRecordService, UserService)

    ShopService.get(function(shop){
      $rootScope.current_shop = shop;
      $rootScope.shop = shop;
      $rootScope.currency = shop.currency;
    });

    $rootScope.go_products_list  = function(branch_id, order_type){ UrlHelperService.go_products_list(branch_id, order_type) }
    $rootScope.go_search_product = function(branch_id, order_type){ UrlHelperService.go_search_product(branch_id, order_type) }
    $rootScope.go_show_product   = function(product, cart_type, category, sub_category){
      var category_id, sub_category_id;
      if(category){
        category_id= category.id;
      }
      if(sub_category){
        sub_category_id= sub_category.id;
      }
      UrlHelperService.go_show_product(product, cart_type, category_id, sub_category_id)
    }

    $rootScope.$on("events:bad_request:custom", function(event, resp){
      if('Cart:InvalidJump' == resp.type){
        $rootScope.alert('无效的操作，跳转中...');
        $rootScope.go_page('main', '/branches/'+resp.branch_id)
      }
      if('Cart:TableTaked' == resp.type){
        $rootScope.alert(resp.errors.join(','));
        $rootScope.go_page('cart', '/branches/'+resp.branch_id+'/orders/'+resp.order_id+'/eat_in_hall/append_itemable_confirm?from_table_cart=true')
        // $rootScope.go_page('order','/branches/'+resp.branch_id+'/orders/eat_in_hall/'+resp.order_id)
      }
    })

    $rootScope.password_modal = {
      show: false,
      user: null,
      password: null,
      success: null,
      authenticate: function(){
        UserService.authenticate_password($rootScope.password_modal.password, function(resp){
          if(!resp.result){
            $rootScope.$emit("events:receive_errors", "支付密码错误")
          }else{
            if($rootScope.password_modal.success) { $rootScope.password_modal.success(); }
          }
        })
      },
      open: function(success){
        UserService.get(function(user){
          $rootScope.password_modal.user = user
        })
        $rootScope.password_modal.success = success
        $rootScope.password_modal.password = null
        $rootScope.password_modal.show = true
        $("input.password-modal-input").select()
      },
      close: function(){
        $rootScope.password_modal.success = null
        $rootScope.password_modal.password = null
        $rootScope.password_modal.show = false
      }
    }

    $rootScope.item_note_modal = {
      show: false,
      item_notes: [],
      success: undefined,
      open: function(item_notes, success){
        this.item_notes = item_notes
        this.show = true
        this.success = success
      },
      close: function(){
        $rootScope.password_modal.show = false
      },
      toggle_item_note: function(item_note){
        item_note.active = !item_note.active
      },
      submit: function(){
        var note = ""
        angular.forEach(this.item_notes, function(item_note){
          if(item_note.active){
            if(note != ""){ note += " "}
            note += item_note.name
          }
        })
        if(this.success){ this.success(note) }
      }
    }

    //console.log(angular.module('ddt_cart').requires);
    $rootScope.go_ng_path();

  }]);
