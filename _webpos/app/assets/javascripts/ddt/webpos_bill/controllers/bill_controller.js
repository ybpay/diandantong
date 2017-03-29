WebposModules.add_controller('bill');

var bill_module = angular.module('webpos.controllers.bill', []);
bill_module.controller('BillController', ['$rootScope', '$scope', '$stateParams', '$filter','BranchService', 'WirePrinterService', 'DiscountListAction', 'WaiterListAction', 'GiftItemListAction', 'SubtractItemListAction', 'SaleListAction', 'PaymentListAction', 'ShiftListAction', 'ComboPackageListAction', 'AntiSettlementListAction', 'OrderCancelListAction', 'QueueListAction','ByWeightProductListAction',
    function ($rootScope, $scope, $stateParams, $filter, BranchService, WirePrinterService, DiscountListAction, WaiterListAction, GiftItemListAction, SubtractItemListAction, SaleListAction, PaymentListAction, ShiftListAction, ComboPackageListAction, AntiSettlementListAction, OrderCancelListAction, QueueListAction,ByWeightProductListAction) {
      $scope.current_tag = null;
      $scope.menus = [
        {name: "折扣清单", tag: 'discount_list', action: DiscountListAction},
        {name: "赠菜清单", tag: 'gift_item_list', action: GiftItemListAction},
        {name: "退菜清单", tag: 'subtract_item_list', action: SubtractItemListAction},
        {name: "销售清单", tag: 'sale_list', action: SaleListAction},
        {name: "套餐清单", tag: 'combo_package_list', action: ComboPackageListAction},
        {name: "交班清单", tag: 'shift_list', action: ShiftListAction},
        {name: "反结帐记录", tag: 'anti_settlement_list', action: AntiSettlementListAction},
        {name: "订单取消记录", tag: 'order_cancel_list', action: OrderCancelListAction},
        {name: "点菜员清单", tag: 'waiter_list', action: WaiterListAction},
        {name: "称重产品清单", tag: 'by_weight_product_list', action: ByWeightProductListAction},
        {name: "第三方支付流水", tag: 'payment_list', action: PaymentListAction},
        {name: "排号记录", tag: 'queue_list', action: QueueListAction}
      ];
      $scope.active_menu = null;
      $scope.init_params = function(){
        $scope.params = {
          start_time: $filter('date')(new Date(), "yyyy-MM-dd") + " 00:00",
          end_time: $filter('date')(new Date(), "yyyy-MM-dd") + " 23:59"
        }
      }

      $scope.change_menu = function (menu) {
        $scope.init_params();
        $scope.current_tag = menu.tag;
        $scope.active_menu = menu;
        menu.action.action($scope);
      };

      var watch_list = ['discount_list', 'combo_package_list', 'payment_list', 'subtract_item_list', 'gift_item_list', 'anti_settlement_list', 'order_cancel_list','waiter_list', 'queue_list','by_weight_product_list', 'shift_list', 'sale_list']

      var clear_watch_start_time = $scope.$watch('params.start_time', function(current, old){
        if(watch_list.indexOf($scope.current_tag) > -1 && !$scope.by_time){
          var strs = current.split(" ")
          var date_part = strs[0]
          var time_part = strs[1]
          if(time_part != "00:00"){
            $scope.params.start_time = date_part + " 00:00"
            clear_watch_start_time();
          }

        }
      })

      var clear_watch_end_time = $scope.$watch('params.end_time', function(current, old){
        if(watch_list.indexOf($scope.current_tag) > -1 && !$scope.by_time){
          var strs = current.split(" ")
          var date_part = strs[0]
          var time_part = strs[1]
          if(time_part != "23:59"){
            $scope.params.end_time = date_part + " 23:59"
            clear_watch_end_time();
          }
        }
      })
      $scope.$on("$destroy", function(){
        if(clear_watch_start_time){clear_watch_start_time()}
        if(clear_watch_end_time){clear_watch_end_time()}
      })

      $scope.branch_id = $stateParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
      })

      $scope.set_to_current_shift = function(){
        $scope.params.start_time = "$current_shift.open_time"
        $scope.params.end_time = "$current_shift.close_time"
      };
      $scope.set_to_last_shift = function(){
        $scope.params.start_time = "$last_shift.open_time"
        $scope.params.end_time = "$last_shift.close_time"
      };

      $scope.print_bill = function(bill){
        if(bill){
          WirePrinterService.print(bill)
        }
      }

      $scope.scroll_top = function(){
        var klass = "." + $scope.current_tag;
        scroll_to(0, klass)
      }

      $scope.scroll_bottom = function(){
        var klass = "." + $scope.current_tag;
        var height = $(klass).height();
        var adjust = height > 400 ? 400 : 140;
        scroll_to(-height + adjust, klass)
      }

      function scroll_to(y, klass){
        var main_part = $(klass).parents('.scroll-wrapper')
        var scroll = $(main_part).data("scroll");
        if(scroll){ scroll.scrollTo(0, y, 500);}
      }
    }])
bill_module.factory('IncludeTimeInterval', ['TimeInterval', function(TimeInterval){
    return {
      action: function($scope, onSetTimeInterval){
        $scope.set_time_interval = function(time_interval){
          $scope.current_time_interval = time_interval
          $scope.time_interval_modal.close();
          if (onSetTimeInterval){
            onSetTimeInterval(time_interval)
          }
        }

        var custom_time_interval = {
          id: null,
          name: '忽略时段'
        }
        $scope.time_intervals = [custom_time_interval];
        $scope.current_time_interval = custom_time_interval;
        TimeInterval.query({ branch_id: $scope.branch_id}, function(time_intervals){
          $scope.time_intervals = [custom_time_interval].concat(time_intervals);
        });

        $scope.time_interval_modal = {
          show: false,
          open: function(){},
          close: function(){ this.show = false},
        }
      }
    }
  }])
bill_module.factory('SaleListAction', ['$timeout', 'BillCenter', 'CategoryService', 'Product', 'IncludeTimeInterval',
    function ($timeout, BillCenter, CategoryService, Product, IncludeTimeInterval) {
      function action($scope) {
        $scope.sale_list = {}
        $scope.selected_category = [];
        $scope.selected_product = [];
        $scope.pay_item_state_collection = [
          {value: 'paid', name: '已付款'},
          {value: 'unpaid', name: '未付款'},
          {value: 'all', name: '所有'},
        ];
        $scope.active_pay_item_state = $scope.pay_item_state_collection[0];

        $scope.change_pay_item_state = function(pay_item_state){
          $scope.active_pay_item_state = pay_item_state;
        }

        $scope.to_f = function(s){return parseFloat(s)}

        $scope.search_sale_list = function(options){
          options = options || {}
          $scope.sale_list = [];
          var category_ids = []
          angular.forEach($scope.selected_category, function(category){
            category_ids.push(category.id)
          })

          var variant_ids = []
          angular.forEach($scope.selected_product, function(product){
            angular.forEach(product.variants, function(variant){
              variant_ids.push(variant.id)
            })
          })

          $scope.params = angular.extend($scope.params, {
            pay_item_state: $scope.active_pay_item_state.value,
            category_ids: category_ids.join(','),
            variant_ids: variant_ids.join(',')
          })

          BillCenter.sale_list(angular.extend({ branch_id: $scope.branch_id, refresh: options.refresh}, $scope.params), function (list) {
            $scope.sale_list = list;
            if(list.$state == 'loading') {
              showLoadingMask();
              $scope.timer = $timeout(function(){
                hideLoadingMask();
                delete options.refresh
                $scope.search_sale_list(options);
              }, 3000);
            } else {
              $timeout.cancel($scope.timer);
            }
          })
        }

        $scope.can_search = function() {
          return !($scope.sale_list.$state == 'loading');
        }

        $scope.print_sale_list = function () {
          $scope.print_bill($scope.sale_list.bill);
        }

        $scope.toggle_category = function(){
          if(!$scope.categories){
            $scope.categories = [];
            CategoryService.query($scope.branch_id, function(categories){
              angular.forEach(categories, function(category){
                $scope.categories.push(category);
                if(category.subs.length != 0){
                  $scope.categories = $scope.categories.concat(category.subs)
                }
              })
              $scope.category_modal.open();
            })
          }else{
            $scope.category_modal.open();
          }
        }

        $scope.remove_category = function(category){ remove_obj($scope.selected_category, category)}
        $scope.remove_product = function(product){ remove_obj($scope.selected_product, product)}

        $scope.$on('destroy',function(){
          $interval.cancel($scope.timer);
        })

        $scope.category_modal = {
          show: false,
          chosen_category_count: 0,
          open: function(){
            this.chosen_category_count = 0;
            angular.forEach($scope.categories, function(category){
              if(category.active){
                $scope.category_modal.chosen_category_count += 1;
              }
            })
            this.show = true;
            $scope.modal = this;
          },
          close: function(){
            this.show = false;
          },
          toggle: function(category){
            category.active = !category.active
            this.chosen_category_count += category.active ? 1 : -1;
          },
          confirm: function(){
            angular.forEach($scope.categories, function(category){
              if(category.active){
                category.active = false;
                if(find_obj($scope.selected_category, 'id_eq', category.id) == null){
                  $scope.selected_category.push(category);
                }
              }
            })
            this.close();
          },
          can_toggle_product: function(){
            return this.chosen_category_count == 1;
          },
          toggle_product: function(){
            var category = find_obj($scope.categories, 'is_active');
            category.active = false;
            Product
              .query({
                branch_id: $scope.branch_id,
                "q[categories_id_eq]": category.id,
                "per_page": 500
              }, function(products){
                $scope.products = products;
                $scope.category_modal.close();
                $scope.product_modal.open();
              })
          }
        }

        $scope.product_modal = {
          show: false,
          open: function(){
            this.show = true;
            $scope.modal = this;
          },
          close: function(){
            this.show = false;
          },
          toggle: function(product){
            product.active = !product.active;
          },
          confirm: function(){
            angular.forEach($scope.products, function(product){
              if(product.active){
                product.active = false;
                if(find_obj($scope.selected_product, 'id_eq', product.id) == null){
                  $scope.selected_product.push(product)
                }
              }
            })
            this.close();
          }
        }

        function find_obj(collection, flag, value){
          var result = null;
          var finder = null;
          if('id_eq' == flag){
            finder = function(obj){
              if(obj.id == value){
                result = obj;
                return;
              }
            }
          }
          if('is_active' == flag){
            finder = function(obj){
              if(obj.active){
                result = obj;
                return;
              }
            }
          }

          angular.forEach(collection, finder)
          return result;
        }

        function remove_obj(collection, obj){
          var idx = collection.indexOf(obj)
          collection.splice(idx, 1);
        }

        IncludeTimeInterval.action($scope, function(time_interval){
          $scope.params.time_interval_id = time_interval.id
        });

      };
      return {
        action: action
      };
    }])
bill_module.factory('ShiftListAction', ['$filter', '$timeout', 'BillCenter', 'IncludeTimeInterval',
    function($filter, $timeout, BillCenter, IncludeTimeInterval){
      function action($scope){
        $scope.shift_list = {};
        $scope.search_key = 'by_shift';
        $scope.by_shift = true;
        $scope.by_time = false;
        $scope.params['date'] = $filter('date')(new Date(), "yyyy-MM-dd");
        $scope.params['start_at'] = '09:00';
        $scope.params['end_at'] = $filter('date')(new Date(), "HH:mm");

        $scope.toggle_search_key = function(key){
          var options = {
            by_shift: false,
            by_time: false,
          }
          $scope.search_key = key;
          options[key] = true
          angular.extend($scope, options)
        }

        $scope.search_shift_list = function(options){
          $scope.searching = true
          options = options || {}
          $scope.shift_list = [];
          angular.extend($scope.params, {search_by: $scope.search_key})
          BillCenter.shift_list(angular.extend({ branch_id: $scope.branch_id, refresh: options.refresh}, $scope.params), function(list){
              $scope.shift_list = list;
              if(list.$state == 'loading') {
                showLoadingMask();
                $scope.timer = $timeout(function(){
                  hideLoadingMask();
                  delete options.refresh
                  $scope.search_shift_list(options);
                }, 3000);
              } else {
                $timeout.cancel($scope.timer);
                $scope.searching = false
              }
          })
        }

        $scope.print_shift_list = function(){
          $scope.print_bill($scope.shift_list.bill);
        }

        //$scope.params['time_interval_id'] = time_interval.id
        IncludeTimeInterval.action($scope, function(time_interval){
          if (time_interval.id){
            $scope.params['start_at'] = time_interval.start
            $scope.params['end_at'] = time_interval.end;
          }
        });
      }

      return {
        action: action
      }
    }
    ])

var factory_names = ['DiscountListAction', 'ComboPackageListAction', 'PaymentListAction', 'SubtractItemListAction', 'GiftItemListAction', 'AntiSettlementListAction', 'OrderCancelListAction','WaiterListAction', 'QueueListAction' ,'ByWeightProductListAction' ];
var list_names = ['discount_list', 'combo_package_list', 'payment_list', 'subtract_item_list', 'gift_item_list', 'anti_settlement_list', 'order_cancel_list','waiter_list', 'queue_list','by_weight_product_list'];
angular.forEach(factory_names, function(factory_name, index){
  bill_module.factory(factory_name, ['$timeout', 'BillCenter', function($timeout, BillCenter){
    function action($scope) {
      var list_name = list_names[index];
      var search_list_name = "search_" + list_name;
      var print_list_name = "print_" + list_name;
      $scope[list_name] = {};
      $scope[search_list_name] = function(options){
        var callee = arguments.callee
        options = options || {}
        $scope[list_name] = [];
        BillCenter[list_name](angular.extend({ branch_id: $scope.branch_id, refresh: options.refresh }, $scope.params), function(list){
          $scope[list_name] = list;
          if(list.$state == 'loading') {
            showLoadingMask();
            $scope.timer = $timeout(function(){
              hideLoadingMask();
              delete options.refresh
              callee.call(options)
            }, 3000);
          } else {
            $timeout.cancel($scope.timer);
          }
        });
      }

      $scope[print_list_name] = function(){
        $scope.print_bill($scope[list_name].bill);
      }
    };
    return {
      action: action
    };
  }]);
});
