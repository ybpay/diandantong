WebposModules.add_controller('users');
angular.module("webpos.controllers.users",[]).
  controller("UsersController",["$rootScope", "$scope", "$stateParams", "$state", "BranchService", "$timeout", "VipLevel", "VipInfo", "PaginateService", "CardReaderService",'Box',
    function($rootScope, $scope, $stateParams, $state, BranchService, $timeout, VipLevel, VipInfo, PaginateService, CardReaderService,Box){

      var branch_id = $stateParams.branch_id;
      $scope.branch_id = branch_id;

      BranchService.get(branch_id, function(branch){ $scope.branch = branch })

      $scope.search_key = ""
      $scope.vip_levels = []
      $scope.vip_infos = []
      $scope.active_vip_info  = null
      $scope.page_vip_infos = null

      VipLevel.query({}).$promise.then(function(vip_levels){
        $scope.vip_levels = vip_levels;
        $scope.vip_levels_no_default = _.filter(vip_levels, function(v){ return !v.is_default })
      })

      function refresh_query(){
        if($scope.search_key && $scope.search_key != ""){
          if($scope.branch.vip_enable_blur_search){
            $scope.page_vip_infos = PaginateService.init(VipInfo.query, {
              "q[vip_no_or_phone_or_name_cont]": $scope.search_key,
            }, query_success)
          }else{
            $scope.page_vip_infos = PaginateService.init(VipInfo.query, {
              "q[vip_no_or_phone_or_name_eq]": $scope.search_key,
            }, query_success)
          }
        }
        $scope.page_vip_infos.query()
      }

      function query_success(vip_infos){
        $scope.vip_infos = vip_infos;
        if($scope.vip_infos.length == 1){
          $scope.choose_vip_info($scope.vip_infos[0], "query")
        }
      }

      $scope.choose_vip_info = function(vip_info, select_mode) {
        $scope.active_vip_info = vip_info
        $state.go("shop.users.detail", { branch_id: branch_id, vip_info_id: vip_info.id, select_mode: select_mode})
      }

      $scope.search_promise = undefined
      $scope.$watch("search_key", function(search_key){
        if(search_key){
          if($scope.search_promise){
            $timeout.cancel($scope.search_promise)
          }
          $scope.search_promise = $timeout(function() { refresh_query(); $scope.search_promise = undefined; }, 1000)
        }else{
          $scope.vip_infos = []
        }
      });

      $scope.read_card = function(){
        CardReaderService.read($rootScope.shop.card_key).then(function(vip_no){
          VipInfo.get({id: vip_no}, function(vip_info){
            $scope.choose_vip_info(vip_info, "read_card")
          })
        });
      }

      $scope.scan_qrcode = function(){
        $rootScope.scan("会员付款码识别", "请顾客出示微信会员付款码，将扫描枪对准进行扫描。(注：扫描枪分一维码/二维码以及光敏/纸质类型，请灵活选择)", function(code){
          if(code){
            VipInfo.get_by_scan_code({scan_code: code}, function(vip_info){
              $scope.choose_vip_info(vip_info, "scan_qrcode")
            })
          }
        })
      }

      $scope.vip_info_modal = {
        show: false,
        vip: {},
        open: function(){
          this.vip = {}
          this.show = true;
        },
        close: function(){ this.show = false },
        can_submit: function(){
          return this.vip && this.vip.name && this.vip.phone && this.vip.vip_level_id
        },
        submit: function(){
          if(this.can_submit()){
            this.vip.from_branch_id = $scope.branch_id
            VipInfo.save({}, { vip_info: this.vip }, function(new_vip){
              $scope.vip_info_modal.close();
              $scope.choose_vip_info(new_vip, "create")
              Box.alert("会员创建成功");
            });
          }else{
            Box.alert('请填写完整信息');
          }
        }
      }

      $scope.create_vip_info = function(){
        $scope.vip_info_modal.open()
      }

      $rootScope.focus('.vip-search-field input')
    }])

