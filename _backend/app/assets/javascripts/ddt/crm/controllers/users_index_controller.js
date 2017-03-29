CrmModules.add_controller('users_index')
angular.module('crm.controllers.users_index', []).
  controller('UsersIndexController', ['$rootScope', '$scope', 'VipInfo', 'LocalStorageService', '$mdDialog', 'PaginateService', 'VipLevel', 'Box', '$mdSidenav', 'Upload',
    function($rootScope, $scope, VipInfo, LocalStorageService, $mdDialog, PaginateService, VipLevel, Box, $mdSidenav, Upload){
      VipLevel.query({}).$promise.then(function(vip_levels){
        $scope.vip_levels = vip_levels
      })
      $scope.all_columns = [
        { key: "user_id"                  , type: "string" , label: "用户ID" }   ,
        { key: "vip_no"                   , type: "string" , label: "会员卡号" }   ,
        { key: "name"                     , type: "string" , label: "会员姓名" }   ,
        { key: "phone"                    , type: "string" , label: "会员手机号" }  ,
        { key: "vip_level_name"           , type: "string" , label: "级别" }     ,
        { key: "vip_level_discount"       , type: "string" , label: "会员折扣" }   ,
        { key: "user_nickname"            , type: "string" , label: "微信昵称" }   ,
        { key: "user_phone"               , type: "string" , label: "微信手机号" }  ,
        { key: "last_placed_at"           , type: "datetime",label: "最后下单时间" } ,
        { key: "card_wallet_amount"       , type: "string" , label: "余额" }  ,
        { key: "credits_wallet_amount"    , type: "string" , label: "积分" }  ,
        { key: "user_placed_orders_count" , type: "string" , label: "累计下单数" }  ,
        { key: "total_amount"             , type: "string" , label: "累计消费金额" } ,
        { key: "total_recharge_money"     , type: "string" , label: "累计充值金额" } ,
        { key: "total_get_credits"        , type: "string" , label: "累计获得积分" } ,
        { key: "total_used_credits"       , type: "string" , label: "累计使用积分" } ,
        { key: "sex_name"                 , type: "string" , label: "性别" }     ,
        { key: "birthday"                 , type: "date"   , label: "生日" }     ,
        { key: "address"                  , type: "string" , label: "地址" }     ,
        { key: "email"                    , type: "string" , label: "邮箱" }     ,
      ]

      $scope.$on("event:vip_info:create", function(event, new_vip_info){
        Box.toast("添加成功")
        $scope.vip_infos.unshift(new_vip_info)
      })

      $scope.$on("event:vip_info:update", function(event, new_vip_info){
        angular.forEach($scope.vip_infos, function(vip_info){
          if(new_vip_info.id == vip_info.id){
            var index = $scope.vip_infos.indexOf(vip_info)
            $scope.vip_infos[index] = new_vip_info
          }
        })
      })

      function set_display_keys(display_keys_str){
        var display_keys = display_keys_str.split(" ")
        $scope.columns = []
        angular.forEach(display_keys, function(key){
          angular.forEach($scope.all_columns, function(column){
            if(key == column.key){
              $scope.columns.push(column)
            }
          })
        })
      }
      var display_keys_str = LocalStorageService.get("vip_info_display_columns") || "user_id user_nickname name sex_name user_phone card_wallet_amount credits_wallet_amount user_placed_orders_count total_amount"
      set_display_keys(display_keys_str)

      $scope.$on("event:choose_vip_info_display_keys", function(event, display_keys_str){
        LocalStorageService.set("vip_info_display_columns", display_keys_str)
        set_display_keys(display_keys_str)
      })

      $scope.reset_search = function(){
        $scope.q = {
          id_eq: "",
          vip_no_or_name_cont: "",
          phone_cont: "",
          vip_level_id_eq: undefined,
          user_unique_user_nickname_cont: "",
          user_phone_cont: "",
          by_applying: undefined,
          sex_eq: undefined,
          blocked: undefined,
          has_wechat_user: undefined,
          s: undefined
        };
        $scope.per_page = 10
      }
      $scope.reset_search()

      function get_query_params(){
        params = {}
        params["per_page"] = $scope.per_page
        for(var key in $scope.q) {
          params["q["+key+"]"] = $scope.q[key]
        }
        return params;
      }
      $scope.search = function(){
        $scope.p = PaginateService.init(VipInfo.query, get_query_params(), function(vip_infos){
          $scope.vip_infos = vip_infos
        })
        $scope.p.query()
      }
      $scope.search()


      $scope.choose_display_columns = function($event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/choose_display_columns.html"),
          clickOutsideToClose:true,
          locals: { data: {
            all_columns: $scope.all_columns,
            columns: $scope.columns,
          }},
          controller: ["$rootScope","$scope", "$mdDialog","data", function($rootScope, $scope, $mdDialog, data){
            $scope.all_columns = angular.copy(data.all_columns)
            $scope.select_columns = angular.copy(data.columns)
            angular.forEach($scope.select_columns, function(sc){
              angular.forEach($scope.all_columns, function(column){
                if(column.key == sc.key){
                  column.selected = true
                }
              })
            })
            $scope.choose_column = function(column, index){
              if($scope.select_columns.indexOf(column) == -1){
                column.selected = true
                $scope.select_columns.push(column)
              }
            }
            $scope.remove_column = function(select_column, index){
              if($scope.select_columns.indexOf(select_column) != -1){
                $scope.select_columns.splice(index, 1)
                angular.forEach($scope.all_columns, function(column){
                  if(column.key == select_column.key){
                    column.selected = false
                  }
                })
              }
            }
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.submit = function(){
              var display_key_str = $.map($scope.select_columns, function(column){
                return column.key
              }).join(" ")
              $rootScope.$broadcast("event:choose_vip_info_display_keys", display_key_str)
              $mdDialog.hide();
            }
          }]
        });
      }

      $scope.toggle_advanced = function(){
        $scope.advanced = !$scope.advanced
      }

      $scope.toggle_action = function(vip_info){
        angular.forEach($scope.vip_infos, function(vi){
          vi.show_action = (vi.id == vip_info.id) && !vi.show_action
        })
      }

      $scope.edit_info = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/vip_info_form.html"),
          clickOutsideToClose:true,
          locals: { data: {
            vip_info: vip_info,
            vip_levels: $scope.vip_levels
          }},
          controller: ["$rootScope","$scope","$mdDialog","Box","data", function($rootScope, $scope, $mdDialog, Box, data){
            $scope.vi = angular.copy(data.vip_info)
            $scope.vip_levels = data.vip_levels
            $scope.close = function(){
              $mdDialog.hide();
            }
            $scope.submit = function(){
              $scope.vi.birthday = moment($scope.vi.birthday).add(8, 'h').toDate()
              VipInfo.update({id: $scope.vi.id}, { vip_info: $scope.vi }).$promise.then(function(vip_info){
                $mdDialog.hide();
                Box.toast("更新成功")
                $rootScope.$broadcast("event:vip_info:update", vip_info)
              })
            }
          }]
        });
      }

      $scope.show_info = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/show_vip_info.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_info: vip_info }},
          controller: ["$scope", "$mdDialog", "data", function($scope, $mdDialog, data){
            $scope.vi = data.vip_info
            $scope.close = function() {
              $mdDialog.hide();
            }
          }]
        });
      }

      $scope.new_vip_info = function($event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/vip_info_form.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_levels: $scope.vip_levels }},
          controller: ["$rootScope","$scope","$mdDialog","data", function($rootScope, $scope, $mdDialog, data) {
            $scope.vip_levels = data.vip_levels
            $scope.vi = {
              vip_no: "",
              name: "",
              phone: "",
              vip_level_id: undefined,
              sex: "male",
              birthday: "",
              address: "",
              email: "",
              note: ""
            };
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.submit = function(){
              VipInfo.save({}, { vip_info: $scope.vi }).$promise.then(function(vip_info){
                $mdDialog.hide();
                $rootScope.$broadcast("event:vip_info:create", vip_info)
              })
            }
          }]
        });
      }

      $scope.send_coupon = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/send_coupon_form.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_info: vip_info }},
          controller: ["$rootScope","$scope","$mdDialog","CouponVersion","VipInfo","Box","data", function($rootScope, $scope, $mdDialog, CouponVersion, VipInfo, Box, data) {
            CouponVersion.query().$promise.then(function(coupon_versions){
              $scope.coupon_versions = coupon_versions
            })
            $scope.sf = {
              coupon_version_id: "",
              count: 1,
              base_user_ids: [data.vip_info.user_id]
            };
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.submit = function(){
              VipInfo.send_coupon({}, { send_coupon_form: $scope.sf }).$promise.then(function(resp){
                $mdDialog.hide();
                Box.toast(resp.result);
                $rootScope.$broadcast("event:send_coupon:success", resp)
              })
            }
          }]
        });
      }

      $scope.edit_pay_password = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/edit_pay_password_form.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_info: vip_info }},
          controller: ["$rootScope","$scope","$mdDialog","VipInfo","Box","data", function($rootScope, $scope, $mdDialog, VipInfo, Box, data) {
            $scope.vi = {
              pay_password: ""
            }
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.submit = function(){
              VipInfo.update({id: data.vip_info.id}, { vip_info: $scope.vi }).$promise.then(function(resp){
                $mdDialog.hide();
                Box.toast("支付密码修改成功")
                $rootScope.$broadcast("event:vip_info:update", resp)
              })
            }
          }]
        });
      }

      $scope.recharge_credits_wallet = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/recharge_credits_wallet_form.html"),
          clickOutsideToClose: true,
          locals: { data: {vip_info: vip_info}},
          controller: ["$rootScope","$scope","$mdDialog","VipInfo","Box","data", function($rootScope, $scope, $mdDialog, VipInfo, Box, data) {
            $scope.recharge = {
              amount: "",
              note: ""
            }

            $scope.close = function(){
              $mdDialog.hide();
            }

            $scope.submit = function(){
              VipInfo.recharge_credits_wallet({id: data.vip_info.id}, { recharge: $scope.recharge}).$promise.then(function(resp){
                $mdDialog.hide();
                Box.toast("充值成功")
                $rootScope.$broadcast("event:vip_info:update", resp)
              })
            }

          }]
        })
      }

      $scope.recharge_card_wallet = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/recharge_card_wallet_form.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_info: vip_info }},
          controller: ["$rootScope","$scope","$mdDialog","VipInfo","Box","data", function($rootScope, $scope, $mdDialog, VipInfo, Box, data) {
            $scope.recharge = {
              amount: "",
              cash_amount: "",
              note: ""
            }
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.submit = function(){
              VipInfo.recharge_card_wallet({id: data.vip_info.id}, { recharge: $scope.recharge }).$promise.then(function(resp){
                $mdDialog.hide();
                Box.toast("充值成功")
                $rootScope.$broadcast("event:vip_info:update", resp)
              })
            }
          }]
        });
      }

      $scope.exchange_card_wallet = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/exchange_card_wallet_form.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_info: vip_info }},
          controller: ["$rootScope","$scope","$mdDialog","VipInfo","Box","data", function($rootScope, $scope, $mdDialog, VipInfo, Box, data) {
            $scope.exchange = {
              amount: "",
              note: ""
            }
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.submit = function(){
              VipInfo.exchange_card_wallet({id: data.vip_info.id}, { exchange: $scope.exchange }).$promise.then(function(resp){
                $mdDialog.hide();
                Box.toast("兑换成功")
                $rootScope.$broadcast("event:vip_info:update", resp)
              })
            }
          }]
        });
      }

      $scope.coupon_logs = function(vip_info,$event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/coupon_logs.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_info: vip_info }},
          controller: ["$rootScope","$scope","$mdDialog","CouponLog","data", function($rootScope, $scope, $mdDialog, CouponLog, data) {
            $scope.q = {
              created_at_gteq: "",
              created_at_lteq: "",
            };
            function get_q(){
              params = {
                vip_info_id: data.vip_info.id
              }
              for(var key in $scope.q) {
                params["q["+key+"]"] = $scope.q[key]
              }
              return params;
            }
            $scope.search = function(){
              $scope.p = PaginateService.init(CouponLog.query, get_q(), function(logs){
                $scope.logs = logs
              })
              $scope.p.query()
            }
            $scope.search()
            $scope.close = function() {
              $mdDialog.hide();
            }
          }]
        });        
      }

      $scope.card_wallet_logs = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/card_wallet_logs.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_info: vip_info }},
          controller: ["$rootScope","$scope","$mdDialog","CardWalletLog","data", function($rootScope, $scope, $mdDialog, CardWalletLog, data) {
            $scope.q = {
              created_at_gteq: "",
              created_at_lteq: "",
            };
            function get_q(){
              params = {
                vip_info_id: data.vip_info.id
              }
              for(var key in $scope.q) {
                params["q["+key+"]"] = $scope.q[key]
              }
              return params;
            }
            $scope.search = function(){
              $scope.p = PaginateService.init(CardWalletLog.query, get_q(), function(logs){
                $scope.logs = logs
              })
              $scope.p.query()
            }
            $scope.search()
            $scope.close = function() {
              $mdDialog.hide();
            }
          }]
        });
      }

      $scope.credits_wallet_logs = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/credits_wallet_logs.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_info: vip_info }},
          controller: ["$rootScope","$scope","$mdDialog","CreditsWalletLog","data", function($rootScope, $scope, $mdDialog, CreditsWalletLog, data) {
            $scope.q = {
              created_at_gteq: "",
              created_at_lteq: "",
            };
            function get_q(){
              params = {
                vip_info_id: data.vip_info.id
              }
              for(var key in $scope.q) {
                params["q["+key+"]"] = $scope.q[key]
              }
              return params;
            }
            $scope.search = function(){
              $scope.p = PaginateService.init(CreditsWalletLog.query, get_q(), function(logs){
                $scope.logs = logs
              })
              $scope.p.query()
            }
            $scope.search()
            $scope.close = function() {
              $mdDialog.hide();
            }
          }]
        });
      }

     $scope.order_logs = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/order_logs.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_info: vip_info }},
          controller: ["$rootScope","$scope","$mdDialog","OrderLog","data", function($rootScope, $scope, $mdDialog, OrderLog, data) {
            $scope.shop_id = $rootScope.shop.id;
            $scope.q = {
              created_at_gteq: "",
              created_at_lteq: "",
            };
            function get_q(){
              params = {
                vip_info_id: data.vip_info.id
              }
              for(var key in $scope.q) {
                params["q["+key+"]"] = $scope.q[key]
              }
              return params;
            }
            $scope.search = function(){
              $scope.p = PaginateService.init(OrderLog.query, get_q(), function(logs){
                $scope.logs = logs
              })
              $scope.p.query()
            }
            $scope.search()
            $scope.close = function() {
              $mdDialog.hide();
            }
          }]
        });
      }

      $scope.apply_vip_action = function(vip_info, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/apply_vip_action.html"),
          clickOutsideToClose:true,
          locals: { data: { vip_info: vip_info }},
          controller: ["$rootScope","$scope","$mdDialog","VipInfo","Box","data", function($rootScope, $scope, $mdDialog, VipInfo, Box, data) {
            $scope.vi = angular.copy(data.vip_info)
            $scope.close = function(){ $mdDialog.hide() }
            $scope.reject = function() {
              VipInfo.reject_apply_vip({id: $scope.vi.id},{}).$promise.then(function(resp){
                $mdDialog.hide();
                Box.toast("会员申请已拒绝")
                $rootScope.$broadcast("event:vip_info:update", resp)
              })
            }
            $scope.agree = function(){
              VipInfo.agree_apply_vip({id: $scope.vi.id},{}).$promise.then(function(resp){
                $mdDialog.hide();
                Box.toast("会员申请已通过")
                $rootScope.$broadcast("event:vip_info:update", resp)
              })
            }
          }]
        });
      }

      $scope.block = function(vip_info, $event){
        Box.confirm("确定禁止微信下单").then(function(){
          VipInfo.block({id: vip_info.id}, { block: true }).$promise.then(function(resp){
            Box.toast("已禁止微信下单")
            $rootScope.$broadcast("event:vip_info:update", resp)
          })
        })
      }

      $scope.cancel_block = function(vip_info, $event){
        VipInfo.block({id: vip_info.id}, { block: false }).$promise.then(function(resp){
          Box.toast("已解除禁止微信下单")
          $rootScope.$broadcast("event:vip_info:update", resp)
        })
      }

      $scope.toggle_batch_select = function(){
        $scope.show_batch_select = !$scope.show_batch_select
      }

      $scope.toggle_select_all = function(){
        $scope.selected_all = !$scope.selected_all
        angular.forEach($scope.vip_infos, function(vi){
          vi.selected = $scope.selected_all
        })
      }

      function batch_action(callback){
        var vip_info_ids = []
        var user_ids = []
        angular.forEach($scope.vip_infos, function(vi){
          if(vi.selected){
            vip_info_ids.push(vi.id)
            if(vi.user_id){ user_ids.push(vi.user_id)}
          }
        })
        if(vip_info_ids.length == 0){
          Box.alert("请先选择用户")
        }else{
          if(callback){ callback(vip_info_ids, user_ids)}
        }
      }

      $scope.batch_send_coupon = function($event){
        batch_action(function(vip_info_ids, user_ids){
          $mdDialog.show({
            parent: angular.element(document.body),
            targetEvent: $event,
            templateUrl: template_url("/dialogs/send_coupon_form.html"),
            clickOutsideToClose:true,
            locals: { data: { base_user_ids: user_ids }},
            controller: ["$rootScope","$scope","$mdDialog","CouponVersion","VipInfo","Box","data", function($rootScope, $scope, $mdDialog, CouponVersion, VipInfo, Box, data) {
              CouponVersion.query().$promise.then(function(coupon_versions){
                $scope.coupon_versions = coupon_versions
              })
              $scope.sf = {
                coupon_version_id: "",
                count: "1",
                base_user_ids: data.base_user_ids
              };
              $scope.close = function() {
                $mdDialog.hide();
              }
              $scope.submit = function(){
                VipInfo.send_coupon({}, { send_coupon_form: $scope.sf }).$promise.then(function(resp){
                  $mdDialog.hide();
                  Box.toast(resp.result);
                  $rootScope.$broadcast("event:send_coupon:success", resp)
                })
              }
            }]
          });
        })
      }

      $scope.batch_destroy = function(){
        batch_action(function(selected_ids){
          Box.confirm("确定删除?(已选人数"+selected_ids.length+")").then(function(){
            VipInfo.batch_destroy({ }, { vip_info_ids: selected_ids }, function(){
              Box.toast("删除成功")
              var new_vip_infos = []
              angular.forEach($scope.vip_infos, function(vi){
                if(selected_ids.indexOf(vi.id) == -1 || vi.user_id){
                  new_vip_infos.push(vi)
                }
              })
              $scope.vip_infos = new_vip_infos
            })
          })
        })
      }

      $scope.batch_credits_clear = function(){
        batch_action(function(selected_ids){
          Box.confirm("确定清空积分?(已选人数"+selected_ids.length+")").then(function(){
            VipInfo.credits_clear({ }, { vip_info_ids: selected_ids }, function(){
              Box.toast("清空积分成功")
            })
          })
        })
      }

      $scope.batch_apply_vip = function(){
        batch_action(function(selected_ids){
          Box.confirm("确定通过会员申请?(已选人数"+selected_ids.length+")").then(function(){
            VipInfo.batch_agree_apply_vip({}, {vip_info_ids: selected_ids}, function(){
              Box.toast("操作成功")
              angular.forEach($scope.vip_infos, function(vi){
                if(selected_ids.indexOf(vi.id) != -1){
                  vi.is_apply_vip = false
                }
              })
            })
          })
        })
      }

      $scope.import_notice = function($event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/import_notice.html"),
          clickOutsideToClose:true,
          controller: ["$rootScope","$scope","$mdDialog", function($rootScope, $scope, $mdDialog) {
            $scope.close = function() {
              $mdDialog.hide();
            }
          }]
        });
      }

      $scope.export_url = function(format){
        return "/backend/crm/shops/" + CrmConst.shop_id + "/vip_infos." + format;
      }

      $scope.import_file = function(files, errFiles){
        $scope.files = files;
        $scope.errFiles = errFiles;
        angular.forEach(files, function(file) {
            file.upload = Upload.upload({
                url: '/backend/crm/shops/'+CrmConst.shop_id+'/vip_infos/import',
                data: { file: file }
            });

            file.upload.then(function (response) {
              Box.toast(response.data.message)
            }, function (response) {
              if (response.status > 0){
                if(response.data.import_failed_file){
                  $scope.show_import_file_error()
                }else{
                  Box.alert(response.data.message)
                }
              }
            }, function (evt) {
              file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total));
            });
        });
      }

      $scope.show_import_file_error = function(){
        $mdDialog.show({
          parent: angular.element(document.body),
          templateUrl: template_url("/dialogs/import_failed.html"),
          clickOutsideToClose:true,
          controller: ["$rootScope","$scope","$mdDialog", function($rootScope, $scope, $mdDialog) {
            $scope.close = function() { $mdDialog.hide(); }
            $scope.import_failed_file = "/backend/crm/shops/" + CrmConst.shop_id + "/vip_infos/import_failed.csv"
          }]
        });
      }
    }
  ])
