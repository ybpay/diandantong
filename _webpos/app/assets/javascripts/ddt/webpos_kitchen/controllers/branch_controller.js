WebposModules.add_controller('branch');
angular.module("webpos.controllers.branch",[]).
  controller("BranchController",["$rootScope", "$scope", "$stateParams","Litp", "NotifyService",'PaginateService','RefreshService','Table','CategoryService','BranchService', 'LitpWaitTimeService',
    function($rootScope, $scope, $stateParams, Litp, NotifyService, PaginateService, RefreshService, Table, CategoryService,BranchService, LitpWaitTimeService){

      var branch_id = $stateParams.branch_id;
      $scope.branch_id = branch_id;
      $scope.litps = []
      $scope.notifications = []
      $scope.page_litps = null;
      $scope.active_table = null;
      $scope.active_category = null;
      $scope.cooks = []

      BranchService.get(branch_id, function(branch){ $scope.branch = branch })

      Litp.cooks({ branch_id: branch_id }).$promise.then(function(cooks){ $scope.cooks = cooks })

      var message_handler = function(msg){
        $scope.notifications.unshift(
        {
          order_number: msg.order_number,
          content: msg.content,
          change_log_ids: msg.change_log_ids
        });
        refresh_count()
        reset_query()
      }

      NotifyService.set_message_handler("COOK_NOTIFICATION", message_handler);

      function query(params, success){
        var filter = {per_page: 50}
        if($scope.active_table){
          filter["q[order_table_id_eq]"] = $scope.active_table.id
        }
        if($scope.active_category){
          filter["filter_category_id"] = $scope.active_category.id
        }
        if($scope.active_cook){
          filter["filter_cook_id"] = $scope.active_cook.id
        }
        $.extend(params, filter)
        $scope.page_litps = PaginateService.init(Litp.query, params, success)
        $scope.page_litps.query();
      }

      $scope.by_pending = function(){
        $scope.toggle_key = "by_pending";
        query({"branch_id": branch_id, "q[state_eq]": "pending", "q[s]": "created_at asc"}, function(litps){
          $scope.litps = litps
        })
      }

      $scope.by_confirmed = function(){
        $scope.toggle_key = "by_confirmed";
        query({"branch_id": branch_id, "q[state_eq]": "confirmed", "q[s]": "created_at asc"}, function(litps){
          $scope.litps = litps
        })
      }

      $scope.by_completed = function(){
        $scope.toggle_key = "by_completed";
        query({"branch_id": branch_id, "q[state_eq]": "completed", "q[s]": "created_at desc"}, function(litps){
          $scope.litps = litps
        })
      }

      $scope.by_canceled = function(){
        $scope.toggle_key = "by_canceled";
        query({"branch_id": branch_id, "q[state_eq]": "canceled", "q[s]": "created_at desc"}, function(litps){
          $scope.litps = litps
        })
      }
      $scope.by_pending()

      // refresh service
      var refresh_count = function(){
        Litp.counts({branch_id: branch_id, skip_mask: true}, function(counts){
          $scope.counts = counts;
        })
      }
      refresh_count();
      RefreshService.add($scope, refresh_count, 30000)

      // refresh time
      var refresh_time = function(){
        $scope.litps.forEach(function(litp){
          if(!litp.created_at_seconds){ litp.created_at_seconds = parseInt(new Date(litp.created_at).getTime() / 1000) }
          if(litp.state == "completed" || litp.state == "canceled"){
            if(!litp.wait_time){
              if(!litp.updated_at_seconds){ litp.updated_at_seconds = parseInt(new Date(litp.updated_at).getTime() / 1000) }
              litp.wait_time = wait_time(litp.created_at_seconds, litp.updated_at_seconds)
            }
          }else{
            litp.wait_time = wait_time(litp.created_at_seconds)
            if($scope.branch){
              var end_seconds = parseInt(new Date().getTime() / 1000);
              var wt = LitpWaitTimeService.get(litp.itemable_id) || $scope.branch.litp_warning_wait_minitue
              litp.is_warning = ((end_seconds - litp.created_at_seconds) >= ( wt * 60 ))
              litp.is_warning_int = litp.is_warning ? 1 : 0
            }
          }
        })
      }
      RefreshService.add($scope, refresh_time, 1000)


      $scope.can_confirm = function(litp){ return litp.state == "pending" }
      $scope.can_complete = function(litp){ return litp.state == "pending" || litp.state == "confirmed"}
      $scope.confirm = function(litp){
        if($scope.can_confirm(litp)){
          Litp.confirm({branch_id: branch_id, id: litp.id}, {}, function(resp){
            litp.state = resp.state
            litp.state_name = resp.state_name
            litp.hide = true
            refresh_count()
          })
        }
      }
      $scope.complete = function(litp){
        if($scope.can_complete(litp)){
          Litp.complete({branch_id: branch_id, id: litp.id}, {}, function(resp){
            litp.state = resp.state
            litp.state_name = resp.state_name
            litp.hide = true
            refresh_count()
          })
        }
      }

      $scope.tables_modal = {
        show: false,
        tables: undefined,
        open: function(){
          if(!this.tables){
            Table.query({branch_id: branch_id}, function(tables){
              $scope.tables_modal.tables = tables;
            });
          }
          this.show = true
        },
        select_table: function(table){
          $scope.active_table = table
          this.show = false
          reset_query()
        }
      }

      $scope.categories_modal = {
        show: false,
        categories: undefined,
        open: function(){
          if(!this.categories){
            CategoryService.query(branch_id, function(resp){
              var all = []
              angular.forEach(resp, function(p){
                all.push(p)
                if(p.subs.length > 0){ all = all.concat(p.subs); }
              })
              $scope.categories_modal.categories = all;
            });
          }
          this.show = true
        },
        select_category: function(category){
          $scope.active_category = category
          this.show = false
          reset_query()
        }
      }

      $scope.cooks_modal = {
        show: false,
        open: function(){
          this.show = true
        },
        select_cook: function(cook){
          $scope.active_cook = cook
          this.show = false
          reset_query()
        }
      }

      function reset_query(){
        if($scope.toggle_key){
          switch($scope.toggle_key){
            case "by_pending":   $scope.by_pending()  ; break;
            case "by_confirmed": $scope.by_confirmed(); break;
            case "by_completed": $scope.by_completed(); break;
            case "by_canceled":  $scope.by_canceled() ; break;
            default:             $scope.by_pending();
          }
        }
      }
      RefreshService.add($scope, reset_query, 30000)
    }]);
