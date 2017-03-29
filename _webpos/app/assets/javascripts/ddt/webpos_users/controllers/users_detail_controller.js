WebposModules.add_controller('users_detail');
angular.module("webpos.controllers.users_detail",[]).
  controller("UsersDetailController",["$rootScope", "$scope", "$stateParams", "Box", "Branch", "VipInfo", "VipLevel", "RechargeProduct", "CardReaderService", "PaginateService","RechargeOrder",'LocalStorageCache',"TempRechargeProduct", "CreditsWallet","CardWalletLog",
    function($rootScope, $scope, $stateParams, Box, Branch, VipInfo, VipLevel, RechargeProduct, CardReaderService, PaginateService,RechargeOrder,LocalStorageCache,TempRechargeProduct, CreditsWallet, CardWalletLog){

      var vip_info_id = $stateParams.vip_info_id
      VipInfo.get({id: vip_info_id}).$promise.then(function(vip_info){
        $scope.vip_info = vip_info
      })

      VipLevel.query({}).$promise.then(function(vip_levels){
        $scope.vip_levels = vip_levels
        $scope.vip_levels_no_default = _.filter(vip_levels, function(v){ return !v.is_default })
      })


      $scope.card_recharge = function(vip_info){
        if($scope.branch.vip_recharge_type == "recharge_product"){
          $scope.recharge_product_modal.open(vip_info)
        }else if($scope.branch.vip_recharge_type == "temp_recharge_product"){
          $scope.temp_recharge_product_modal.open(vip_info)
        }
      }

      $scope.show_recharge = function(){
        return !($scope.branch && $scope.branch.disable_recharge_when_query && $stateParams.select_mode == "query")
      }

      $scope.recharge_product_modal = {
        show: false,
        recharge_products: [],
        vip_info: null,
        open: function(vip_info){
          RechargeProduct.query({branch_id: $scope.branch_id}).$promise.then(function(rps){
            $scope.recharge_product_modal.recharge_products = rps
          })
          this.show = true
          this.vip_info = vip_info
        },
        select_recharge_product: function(rp){
          var branch_id = $stateParams.branch_id
          $rootScope.auth_action('branch', 'recharge_order', 'create', {branch_id: branch_id}, function(){
            RechargeOrder.save({ branch_id: branch_id }, {
              cart: {
                line_items_attributes: [{
                  itemable_type: "Ddt::RechargeProduct",
                  itemable_id: rp.id,
                  quantity: 1,
                }],
                vip_info_id: $scope.vip_info.id
              }
            }).$promise.then(function(resp){
              var after_settle_full_path = "/webpos/users#/shop/branches/"+branch_id+"/users/"+$scope.vip_info.id + "/query"
              LocalStorageCache.set("after_settle_full_path", after_settle_full_path)
              $rootScope.go_path("/webpos#/branches/"+branch_id+"/orders/"+ resp.order_id+"/settle/"+resp.type_str)
            })
          })
        }
      }

      $scope.temp_recharge_product_modal = {
        show: false,
        product: {
          price: "100",
          recharge_amount: "100",
          extra_credits: "0"
        },
        vip_info: null,
        open: function(vip_info){
          this.show = true
          this.vip_info = vip_info
        },
        close: function(){
          this.show = false
        },
        can_submit: function(){
          return parseFloat(this.product.price) > 0 && parseFloat(this.product.recharge_amount) > 0 && parseFloat(this.product.extra_credits) >= 0 && parseFloat(this.product.price) <= parseFloat(this.product.recharge_amount)
        },
        submit: function(){
          if(this.can_submit()){
            var branch_id = $stateParams.branch_id
            TempRechargeProduct.save({}, { temp_recharge_product: this.product }).$promise.then(function(product){
              $rootScope.auth_action('branch', 'recharge_order', 'create', {branch_id: branch_id}, function(){
                RechargeOrder.save({ branch_id: branch_id }, {
                  cart: {
                    line_items_attributes: [{
                      itemable_type: "Ddt::TempRechargeProduct",
                      itemable_id: product.id,
                      quantity: 1,
                    }],
                    vip_info_id: $scope.vip_info.id
                  }
                }).$promise.then(function(resp){
                  var after_settle_full_path = "/webpos/users#/shop/branches/"+branch_id+"/users/"+$scope.vip_info.id + "/query"
                  LocalStorageCache.set("after_settle_full_path", after_settle_full_path)
                  $rootScope.go_path("/webpos#/branches/"+branch_id+"/orders/"+ resp.order_id+"/settle/"+resp.type_str)
                })
              })
            })
          }
        }
      }

      $scope.init_card = function(){
        Box.confirm("确定初始化卡片?", function(){
          CardReaderService.init_card($rootScope.shop.card_key).then(function(resp){
            if (resp){
              Box.alert("卡片初始化成功!")
            }
          })
        })
      }

      $scope.clear_card = function(){
        Box.confirm("确定重置并清空卡片信息?", function(){
          CardReaderService.clear_card().then(function(resp){
            Box.alert("重置并清空卡片信息成功!")
          })

        })
      }

      $scope.read_card = function(){
        CardReaderService.read($rootScope.shop.card_key).then(function(resp){
          if(resp){
            Box.alert("读卡:" + resp)
          }
        });
      }

      $scope.write_card = function(){
        Box.confirm("确定将会员信息写入卡片?", function(){
          CardReaderService.write($rootScope.shop.card_key, $scope.vip_info.vip_no).then(function(resp){
            if (resp) {
              Box.alert("写卡成功!")
            }
          })
        })
      }

      $scope.bind_user = function(){
        $rootScope.vip_scan_verify("会员信息微信绑定", "请顾客使用微信扫描此二维码即可自动与该会员卡进行绑定", function(vip_info){
          Box.confirm("确定将会员信息和微信用户绑定?", function(){
            VipInfo.merge({ id: $scope.vip_info.id }, { source_vip_info_id: vip_info.id }).$promise.then(function(vip_info){
              $scope.vip_info = vip_info
              Box.alert("绑定成功")
            })
          })
        }, true, false)
      }

      $scope.vip_info_modal = {
        show: false,
        vip: {},
        open: function(){
          this.vip = angular.copy($scope.vip_info)
          this.show = true;
        },
        close: function(){ this.show = false },
        can_submit: function(){
          return this.vip && this.vip.name && this.vip.phone && this.vip.vip_level_id
        },
        submit: function(){
          if(this.can_submit()){
            VipInfo.update({id: this.vip.id }, { vip_info: this.vip }, function(new_vip){
              $scope.vip_info_modal.close();
              $scope.vip_info = new_vip;
              Box.alert("信息更新成功");
            });
          }else{
            Box.alert('请填写完整信息');
          }
        }
      }

      $scope.update_vip_info = function(){
        $scope.vip_info_modal.open()
      }

      // wallet_logs
      $scope.log_modal = {
        show: false,
        title: "",
        type: "",
        wallet_logs: [],
        page_wallet_logs: null,
        open: function(type){
          if(type == "card"){
            this.title = "余额日志"
            this.type = "card_wallet_logs"
          }else if(type == "credits"){
            this.title = "积分日志"
            this.type = "credits_wallet_logs"
          }
          this.wallet_logs = []
          this.page_wallet_logs = null

          this.page_wallet_logs = PaginateService.init(VipInfo.wallet_logs, {
            id: $scope.vip_info.id,
            wallet_logs_type: $scope.log_modal.type
          }, function(wallet_logs) {
            $scope.log_modal.wallet_logs = wallet_logs;
          });
          this.page_wallet_logs.query();
          this.show = true
        },
        can_change_note: function(log){
          return this.type == "card_wallet_logs" && (!log.note || log.note.indexOf("已开票") == -1)
        },
        change_note: function(log){
          CardWalletLog.change_note({ vip_info_id: $scope.vip_info.id, id: log.id }, { note: " 已开票"}).$promise.then(function(resp){
            log.note = resp.note
          })
        }
      }

      // credits exchange
      $scope.credits_exchange_modal = {
        show: false,
        amount: "",
        note: "",
        can_open: function(){
          return $scope.branch && $scope.branch.allow_credits_exchange_and_get
        },
        open: function(){
          this.amount = ""
          this.note = ""
          this.show = true;
        },
        close: function(){ this.show = false },
        can_submit: function(){
          return this.amount && parseInt(this.amount) > 0 && parseInt(this.amount) <= parseInt($scope.vip_info.credits_wallet.amount)
        },
        submit: function(){
          if(this.can_submit()){
            CreditsWallet.exchange({id: $scope.vip_info.credits_wallet.id }, {
                exchange: {
                  amount: this.amount,
                  note: this.note,
                  branch_id: $stateParams.branch_id
                }
              }, function(resp){
              $scope.credits_exchange_modal.close();
              $scope.vip_info.credits_wallet = resp.credits_wallet;
              Box.alert("积分兑换成功");
            });
          }
        }
      }

      // 积分充值
      $scope.credits_get_modal = {
        show: false,
        amount: "",
        note: "",
        can_open: function(){
          return $scope.branch && $scope.branch.allow_credits_exchange_and_get
        },
        open: function(){
          this.amount = ""
          this.note = ""
          this.show = true;
        },
        close: function(){ this.show = false },
        can_submit: function(){
          return this.amount && parseInt(this.amount) > 0
        },
        submit: function(){
          if(this.can_submit()){
            CreditsWallet.get({id: $scope.vip_info.credits_wallet.id }, {
                get: {
                  amount: this.amount,
                  note: this.note,
                  branch_id: $stateParams.branch_id
                }
              }, function(resp){
              $scope.credits_get_modal.close();
              $scope.vip_info.credits_wallet = resp.credits_wallet;
              Box.alert("积分充值成功");
            });
          }
        }
      }
    }]);
