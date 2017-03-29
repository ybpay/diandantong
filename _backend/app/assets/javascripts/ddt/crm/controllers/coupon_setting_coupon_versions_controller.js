CrmModules.add_controller('coupon_setting_coupon_versions')
angular.module('crm.controllers.coupon_setting_coupon_versions', []).
  controller('CouponSettingCouponVersionsController', ['$rootScope', '$scope','CouponVersion', '$mdDialog', 'Box',
    function($rootScope, $scope, CouponVersion, $mdDialog, Box){
      $scope.coupon_versions = [];
      $scope.query_params = {};
      CouponVersion.query($scope.query_params).$promise.then(function(resp){
        $scope.coupon_versions = resp
      })

      $scope.$on("event:coupon_version:create", function(event, new_coupon_version){
        $scope.coupon_versions.push(new_coupon_version)
        Box.toast("添加成功")
      })

      $scope.$on("event:coupon_version:update", function(event, new_coupon_version){
        Box.toast("更新成功")
        angular.forEach($scope.coupon_versions, function(coupon_version){
          if(new_coupon_version.id == coupon_version.id){
            var index = $scope.coupon_versions.indexOf(coupon_version)
            $scope.coupon_versions[index] = new_coupon_version
          }
        })
      })

      $scope.new_coupon_version = function($event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/coupon_version_form.html"),
          clickOutsideToClose:true,
          controller: ["$rootScope","$scope","$mdDialog","Branch","CouponVersionModel", function($rootScope, $scope, $mdDialog, Branch, CouponVersionModel) {
            $scope.cv = CouponVersionModel.build()
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.submit = function(){
              CouponVersion.save({}, { coupon_version: CouponVersionModel.to_params($scope.cv) }).$promise.then(function(coupon_version){
                $mdDialog.hide();
                $rootScope.$broadcast("event:coupon_version:create", coupon_version)
              })
            }
            $scope.branch_select_options = {
              query: function(query){
                Branch.query({"q[name_cont]": query.term }).$promise.then(function(branches){
                  query.callback({ results: branches })
                })
              }
            }
            $scope.add_instruction = function(){ $scope.cv.coupon_usage_instructions.push({content: ""}) }
            $scope.delete_instruction = function(instruction){ instruction._destroy = true }
          }]
        });
      }

      $scope.edit_coupon_version = function(coupon_version, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/coupon_version_form.html"),
          clickOutsideToClose:true,
          controller: ["$rootScope","$scope", "$mdDialog","Branch","CouponVersionModel", function($rootScope, $scope, $mdDialog, Branch, CouponVersionModel) {
            $scope.cv = angular.copy(coupon_version)
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.submit = function(){
              CouponVersion.update({id: $scope.cv.id}, { coupon_version: CouponVersionModel.to_params($scope.cv) }).$promise.then(function(resp){
                $mdDialog.hide();
                $rootScope.$broadcast("event:coupon_version:update", resp)
              })
            }
            $scope.branch_select_options = {
              query: function(query){
                Branch.query({"q[name_cont]": query.term }).$promise.then(function(branches){
                  query.callback({ results: branches })
                })
              }
            }
            $scope.add_instruction = function(){ $scope.cv.coupon_usage_instructions.push({content: ""}) }
            $scope.delete_instruction = function(instruction){ instruction._destroy = true }
          }]
        });
      }

      $scope.destroy_coupon_version = function(coupon_version){
        Box.confirm("确认删除"+ coupon_version.name + "?").then(function(){
          CouponVersion.destroy({id: coupon_version.id}, {}, function(){
            var index = $scope.coupon_versions.indexOf(coupon_version)
            $scope.coupon_versions.splice(index, 1)
            Box.toast("删除成功")
          })
        })
      }

      $scope.toggle_action = function(coupon_version){
        angular.forEach($scope.coupon_versions, function(cv){
          cv.show_action = (cv.id == coupon_version.id) && !cv.show_action
        })
      }

      $scope.coupon_photos = function(coupon_version, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/coupon_photos.html"),
          clickOutsideToClose:true,
          locals: { data: { coupon_version: coupon_version }},
          controller: ["$rootScope","$scope", "$mdDialog","CouponPhoto","Upload","$timeout","data", function($rootScope, $scope, $mdDialog, CouponPhoto, Upload, $timeout, data) {
            $scope.cv = angular.copy(data.coupon_version)
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.photos = [];
            CouponPhoto.query({coupon_version_id: $scope.cv.id}).$promise.then(function(resp){
              $scope.photos = resp
            })
            $scope.uploadFiles = function(files, errFiles) {
              $scope.files = files;
              $scope.errFiles = errFiles;
              angular.forEach(files, function(file) {
                  file.upload = Upload.upload({
                      url: '/backend/crm/coupon_versions/'+$scope.cv.id+'/coupon_photos/',
                      data: { coupon_photo: { image: file }}
                  });

                  file.upload.then(function (response) {
                      $timeout(function () {
                          $scope.photos.push(response.data)
                      });
                  }, function (response) {
                      if (response.status > 0)
                          $scope.errorMsg = response.status + ': ' + response.data;
                  }, function (evt) {
                      file.progress = Math.min(100, parseInt(100.0 *
                                               evt.loaded / evt.total));
                  });
              });
            }

            $scope.can_remove = function(){
              return $scope.photos.filter(function(p){ return p.selected }).length > 0
            }
            $scope.remove_selected_photos = function(){
              var pids = $scope.photos.filter(function(p){ return p.selected }).map(function(p){ return p.id})
              CouponPhoto.batch_destroy({coupon_version_id: $scope.cv.id}, {photo_ids: pids}).$promise.then(function(){
                $scope.photos = $scope.photos.filter(function(p){return !p.selected})
              })
            }
          }]
        });
      }
    }
  ])
