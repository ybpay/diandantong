WebposModules.add_controller('branch_delivery')
angular.module('webpos.controllers.branch_delivery', []).
  controller('branchDeliveryController',
    ['$rootScope','$scope','$timeout', '$location','$routeParams','BranchService','DeliveryCartService','ShipmentService','FormElementService', 'AddressService', 'CartItemableAction', 'GeolocationService',
    function($rootScope, $scope, $timeout, $location, $routeParams, BranchService, DeliveryCartService, ShipmentService, FormElementService, AddressService, CartItemableAction, GeolocationService){
      init_delivery();

      $scope.branch_id = $routeParams.branch_id
      CartItemableAction.init($scope.branch_id, "delivery", function(cart){ $scope.cart = cart })
      $scope.change_active_line_item = CartItemableAction.change_active_line_item;
      $scope.add_itemable            = CartItemableAction.add_itemable;
      $scope.remove_itemable         = CartItemableAction.remove_itemable;
      $scope.clear                   = CartItemableAction.clear;

      $scope.change_note             = CartItemableAction.change_note;
      $scope.batch_change_note       = CartItemableAction.batch_change_note;
      $scope.change_gift             = CartItemableAction.change_gift;
      $scope.change_weight           = CartItemableAction.change_weight;
      $scope.edit_line_item          = CartItemableAction.edit_line_item;

      var clear_choose_itemable_listener = $scope.$on("event:choose_itemable", function(event, itemable){
        CartItemableAction.add_itemable_separate(itemable)
      })
      $scope.$on("$destroy", function(){
        clear_choose_itemable_listener();
        CartItemableAction.dispose()
      })

      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        ShipmentService.query('delivery_zones',$scope.branch_id, function(delivery_zones){
          $scope.delivery_zones = delivery_zones;
        })
        ShipmentService.query('delivery_mans',$scope.branch_id, function(delivery_mans){
          $scope.delivery_mans = delivery_mans;
        })
        ShipmentService.query('delivery_dates',$scope.branch_id, function(delivery_dates){
          $scope.delivery_dates = delivery_dates;
          if($scope.delivery_dates.length > 0){
            $scope.shipment.delivery_date = $scope.delivery_dates[0]
            $scope.change_delivery_date()
          }
        })
        FormElementService.query($scope.branch_id, function(form_elements){
          $scope.form_elements = form_elements;
        })

        if(!$scope.branch.is_charge_by_distance){
          var clear_watch_delivery_zone = $scope.$watch("user.delivery_zone", function(current, before){
            if(current){
              $scope.delivery_fee = current.cost;
            }
          })
          $scope.$on("$destroy", function(){
            clear_watch_delivery_zone()
          })
        }

        // set_region(parseFloat($scope.branch.latitude), parseFloat($scope.branch.longitude) )


      })

      $scope.can_show_delivery_zone = function(){ return $scope.delivery_zones && $scope.delivery_zones.length > 0}
      $scope.can_show_delivery_date = function(){ return $scope.delivery_dates && $scope.delivery_dates.length > 0}
      $scope.can_show_delivery_man  = function(){ return $scope.delivery_mans && $scope.delivery_mans.length  > 0}
      $scope.can_show_delivery_time = function(){ return $scope.delivery_times && $scope.delivery_times.length > 0}

      $scope.change_delivery_date = function() {
        $scope.active_delivery_date = $scope.shipment.delivery_date;
        $scope.delivery_times = $scope.shipment.delivery_date.delivery_times;
      }

      function init_delivery(){
        $scope.cart = null
        $scope.active_line_item = null
        $scope.shipment = {
          name: '',
          phone: '',
          building: '',
          room_no: '',
          delivery_zone: null,
          note: '',
          latitude: null,
          longitude: null,
        }
        var number = $location.search().caller_number
        if(number){
          AddressService.search(number, function(addresses){
            $scope.addresses_collection = addresses
            if(addresses.length > 0){
              $scope.select_address(addresses[0])
            }else{
              $scope.shipment.phone = number
            }
          })
        }
        $scope.delivery_fee = 0.0;

        $scope.address_modal = {
          show: false,
          open: function(){
            this.k = 'main';/*main or posi*/
            this.show = true;
          },
          toggle: function(k){
            this.k = k;
            if('posi' == k){
              this.keyworld = $scope.shipment.building;
              this.addresses = [];
              this.selected = null;
            }
          },
          finish_search: function(){
            if(this.selected){
              var address = this.selected;
              console.log(address)
              $scope.shipment.building  = address.name
              $scope.shipment.latitude  = address.latLng.lat;
              $scope.shipment.longitude = address.latLng.lng;
              this.addresses = [];
              this.keyworld = '';
              this.toggle('main');
            }else{
              $scope.shipment.building  = $scope.address_modal.keyworld
              this.addresses = [];
              this.keyworld = '';
              this.toggle('main');
              // $rootScope.alert('必须选择一个地址');
            }

          },
          select_address: function(address){
            this.selected = address;
          }
        }
      }


      function set_region(latitude, longitude){
        GeolocationService.get_address(latitude, longitude, function(result){
          $scope.region = result.province + result.city;
        });
      }

      var timer = undefined;
      function cancel_query_timer(){
        if(timer){
          $timeout.cancel( timer );
        }
      }

      var clear_watch_keyword = $scope.$watch("address_modal.keyworld", function(new_value, old_value){
        if(new_value && new_value.length >= 2){
          cancel_query_timer();
          timer = $timeout(function(){
            GeolocationService.search_address($scope.region, new_value, function(addresses){
              $scope.address_modal.addresses = addresses.slice(0, 7);
              $scope.$apply(function(){})
            })
          }, 300);
        }
      })



      var clear_watch_user_phone = $scope.$watch("shipment.phone", function(phone){
        if(phone && phone.length >= 5){
          AddressService.search(phone, function(addresses){
            $scope.addresses_collection = addresses
          })
        }
      })
      $scope.$on("$destroy", function(){
        clear_watch_user_phone();
        clear_watch_keyword();
      })

      $scope.select_address = function(address){
        $scope.shipment.name    = address.name;
        $scope.shipment.building = address.building;
        $scope.shipment.room_no = address.room_no;
        $scope.shipment.phone   = address.phone;
        $scope.shipment.latitude = address.latitude;
        $scope.shipment.longitude = address.longitude;
      }

      $scope.order_total = function(){
        var total = 0;
        if($scope.cart){ total += $scope.cart.total}
        if($scope.delivery_fee){ total += parseFloat($scope.delivery_fee)}
        return total
      }

      $scope.form_contents = function() {
        var form_records = [];
        $.each($scope.form_elements, function() {
          form_records.push(this["record"]);
        });

        return form_records;
      };

      $scope.is_form_contents_valid = function() {
        var errors = [];
        $.each($scope.form_elements, function() {
          if (typeof(this.record.content) == 'undefined') {
            this.record.content = '';
          }
          var content = this.record.content.toString();

          if(this.need && content.match(/^\S+$/) == null) {
            errors.push(this.label + "不能为空");
          }
        });

        return errors;
      };

      $scope.is_building_valid = function(){
        // if($rootScope.shop.enable_foreign){
          return $scope.shipment.building;
        // }else{
        //   return $scope.shipment.latitude && $scope.shipment.longitude && $scope.shipment.building;
        // }
      }

      $scope.is_delivery_zone_valid = function(){
        if($scope.can_show_delivery_zone() && !$scope.shipment.delivery_zone){return false}
        return true
      }
      $scope.is_delivery_date_valid = function(){
        if($scope.can_show_delivery_date() && !$scope.shipment.delivery_date){return false}
        return true
      }
      $scope.is_delivery_time_valid = function(){
        if($scope.can_show_delivery_time() && !$scope.shipment.delivery_time){return false}
        return true
      }
      $scope.can_submit = function(){
        if(!$scope.is_delivery_zone_valid()){return false;}
        if(!$scope.is_delivery_date_valid()){return false;}
        if(!$scope.is_delivery_time_valid()){return false;}
        if(!$scope.is_building_valid()){return false;}
        return !$rootScope.is_submiting 
               && $scope.cart 
               && $scope.cart.line_items.length > 0 
               && $scope.shipment.name 
               && $scope.shipment.phone 
               && $scope.is_form_contents_valid().length == 0
      }



      $scope.submit = function(){
        if($scope.can_submit()){
          $rootScope.is_submiting = true
          var params = {};
          $.extend(params, $scope.shipment);
          params.form_contents = $scope.form_contents();
          params.bill_type = $rootScope.order_bill_type();
          params.is_local_printed = $rootScope.local_printer_configed();
          DeliveryCartService.place_cart($scope.branch_id, params, function(result){
            $rootScope.is_submiting = false
            init_delivery();
            var bill = result.bill;
            var order = result;
            var go_to_settle = function(){$rootScope.go("/branches/"+$scope.branch_id+"/orders/"+order.id+"/settle/"+order.type_str)}

            if($rootScope.local_printer_configed()){
              $rootScope.local_print_order_bill(bill)
              $rootScope.confirm("要现在支付？", go_to_settle)
            }else if($scope.branch.webpos_autoprinter_configed){
              $rootScope.confirm("要现在支付？", go_to_settle)
            }else{
              $rootScope.confirm("您要打印该订单或者去支付？", function(){
                $rootScope.wire_print_order_bill(order)
              }, "打印订单", go_to_settle, "去支付")
            }

          })
        }else{
          var errors = []
          if(!$scope.cart || $scope.cart.line_items.length === 0){ errors.push("订单不能为空")}
          if(!$scope.shipment.name){ errors.push("姓名不能为空")}
          if(!$scope.shipment.phone){ errors.push("电话不能为空")}
          if(!$scope.is_building_valid()){ errors.push("小区不能为空")}
          if(!$scope.is_delivery_zone_valid()){ errors.push("配送区域不能为空")}
          if(!$scope.is_delivery_date_valid()){ errors.push("配送日期不能为空")}
          if(!$scope.is_delivery_time_valid()){ errors.push("配送时间不能为空")}
          if(!$scope.is_form_contents_valid().length == 0){ errors.concat($scope.is_form_contents_valid())}
          // console.log(errors)
          $rootScope.alert(errors.join("<br/>"))
        }
      }
    }])
