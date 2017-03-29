WebposModules.add_action('set_reprint')
angular.module('webpos.actions.set_reprint',[]).
  factory('SetReprintAction',
    ['$rootScope','$routeParams', 'PrinterService','PrintService',
    function($rootScope, $routeParams, PrinterService, PrintService){

      var current_printer = { id: null, name: "当前打印机"};
      var get_order = undefined;
      function init(gorder){
        get_order = gorder
        $rootScope.reprint_targets = []
        set_modal()
      }

      function dispose(){
        $rootScope.reprint_targets = []
        $rootScope.reprint_modal = undefined
      }

      function choose_reprint_targets(){
        PrinterService.query($routeParams.branch_id, function(targets){
          targets.unshift(current_printer);
          $rootScope.reprint_targets = targets;
          $rootScope.reprint_modal.open();
        })
      }

      function reprint(){
        var need_print_current = false;
        var target_ids = []
        angular.forEach($rootScope.reprint_targets, function(target){
          if(target.active){
            if(target.id == null){
              need_print_current = true;
            }else{
              target_ids.push(target.id);
            }
          }
        })

        if(target_ids.length > 0){
          PrinterService.reprint($routeParams.branch_id, target_ids, $rootScope.reprint_modal.note, get_order().id, function(){
            $rootScope.alert("其他打印机补打成功");
          })
        }

        if(need_print_current){
          print_in_current_printer();
        }
        current_printer.active = false;
      }

      function set_modal(){
        $rootScope.reprint_modal = {
          show: false,
          choosen_target_count: 0,
          click_printer: function(target){
            if(target.active){
              this.choosen_target_count--;
              target.active = false;
            }else{
              this.choosen_target_count++;
              target.active = true;
            }
          },
          open: function(){
            current_printer.active = false
            this.choosen_target_count = 0;
            this.show = true
          },
          can_submit: function(){
            return this.choosen_target_count > 0;
          },
          cancel: function(){
            this.show = false;
          },
          submit: function(){
            if(this.choosen_target_count <=0 ){return;}
            reprint();
            this.show = false;
          }
        }
      }

      function print_in_current_printer(){
        addition_infos = []
        addition_infos.push("－－－－－－－－－－－－")
        addition_infos.push("[小票补打]")
        if($rootScope.reprint_modal.note){
          addition_infos.push("备注: " + $rootScope.reprint_modal.note)
        }
        PrintService.print_order_bill(get_order(), addition_infos, {is_reprint_bill: true})
      }


      return {
        init: init,
        dispose: dispose,
        choose_reprint_targets: choose_reprint_targets,
      }
    }])
