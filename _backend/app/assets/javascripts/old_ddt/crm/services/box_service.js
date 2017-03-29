CrmModules.add_service('box')
angular.module('crm.services.box', []).
  factory('Box', ['$mdDialog', '$mdToast', function($mdDialog, $mdToast){
    return {
      alert: alert,
      toast: toast,
      confirm: confirm,
    }

    function alert(info){
      var content = (angular.isArray(info) ? info.join(",") : info);
      var options = $mdToast.simple(content).action('X').highlightAction(false).position('bottom right left');
      options._options.noCancelTimeout = true;
      options._options.zIndexBase = 100;
      $mdToast.show(options);
      // $mdDialog.show(
      //   $mdDialog.alert()
      //     .parent(angular.element(document.body))
      //     .clickOutsideToClose(true)
      //     // .title(info)
      //     .textContent(content)
      //     .ok('确认')
      // );
    }

    function toast(info){
      var options = $mdToast.simple(info).action('x').highlightAction(false).position('top right');
      options._options.noCancelTimeout = true;
      options._options.zIndexBase = 100;
      $mdToast.show(options);
    }

    function confirm(info, ok_text, cancel_text){
      ok_text = (typeof ok_text === "undefined" ? "确定" : ok_text)
      cancel_text = (typeof cancel_text === "undefined" ? "取消" : cancel_text)
      var confirm = $mdDialog.confirm()
          .title(info)
          .clickOutsideToClose(true)
          .ok(ok_text)
          .cancel(cancel_text);
      return $mdDialog.show(confirm);
    }
  }])