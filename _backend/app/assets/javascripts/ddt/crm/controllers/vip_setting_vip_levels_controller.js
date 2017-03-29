CrmModules.add_controller('vip_setting_vip_levels')
angular.module('crm.controllers.vip_setting_vip_levels', []).
  controller('VipSettingVipLevelsController', ['$rootScope', '$scope','VipLevel', '$mdDialog', 'Box',
    function($rootScope, $scope, VipLevel, $mdDialog, Box){
      $scope.vip_levels = [];
      $scope.vip_level_not_unique = false
      $scope.query_params = {};

      function set_unique_flag(){
        $scope.vip_level_not_unique = false;
        level_count = {};
        angular.forEach($scope.vip_levels, function(vip_level){
          count = level_count[vip_level.level]
          if(typeof count == 'undefined'){
            level_count[vip_level.level] = 1;
          }else{
            $scope.vip_level_not_unique = true;
            return true;
          }
        })
        return false;
      }
      $scope.$on('event:vip_levels:changed', set_unique_flag)

      VipLevel.query($scope.query_params).$promise.then(function(resp){
        $scope.vip_levels = resp
        $scope.$emit('event:vip_levels:changed')
      })

      $scope.$on("event:vip_level:create", function(event, new_vip_level){
        $scope.vip_levels.push(new_vip_level)
        $scope.$emit('event:vip_levels:changed')
        Box.toast("添加成功")
      })

      $scope.$on("event:vip_level:update", function(event, new_vip_level){
        Box.toast("更新成功")
        angular.forEach($scope.vip_levels, function(vip_level){
          if(new_vip_level.id == vip_level.id){
            var index = $scope.vip_levels.indexOf(vip_level)
            $scope.vip_levels[index] = new_vip_level
          }
        })
        $scope.$emit('event:vip_levels:changed')
      })

      $scope.new_vip_level = function($event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/vip_level_form.html"),
          clickOutsideToClose:true,
          controller: ["$rootScope","$scope","$mdDialog", function($rootScope, $scope, $mdDialog) {
            $scope.vip_level = {
              name: "",
              discount: "1.0",
              level: "1",
              auto_upgrade: false,
              upgrade_total_amount: undefined,
              upgrade_recharge_money: undefined,
              upgrade_get_credits: undefined,
            };
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.submit = function(){
              VipLevel.save({}, { vip_level: $scope.vip_level }).$promise.then(function(vip_level){
                $mdDialog.hide();
                $rootScope.$broadcast("event:vip_level:create", vip_level)
              })
            }
          }]
        });
      }

      $scope.edit_vip_level = function(vip_level, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/vip_level_form.html"),
          clickOutsideToClose:true,
          controller: ["$rootScope","$scope","$mdDialog", function($rootScope, $scope, $mdDialog) {
            $scope.vip_level = angular.copy(vip_level)
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.submit = function(){
              VipLevel.update({id: $scope.vip_level.id}, { vip_level: $scope.vip_level }).$promise.then(function(resp){
                $mdDialog.hide();
                $rootScope.$broadcast("event:vip_level:update", resp)
              })
            }
          }]
        });
      }

      $scope.destroy_vip_level = function(vip_level){
        Box.confirm("确认删除"+ vip_level.name + "?").then(function(){
          VipLevel.destroy({id: vip_level.id}, {}, function(){
            var index = $scope.vip_levels.indexOf(vip_level)
            $scope.vip_levels.splice(index, 1)
            Box.toast("删除成功")
            $scope.$emit('event:vip_levels:changed')
          })
        })
      }

      $scope.toggle_action = function(vip_level){
        angular.forEach($scope.vip_levels, function(vl){
          vl.show_action = (vl.id == vip_level.id) && !vl.show_action
        })
      }
    }
  ])
