//WebposModules.add_directive('wp_btn')
//angular.module('webpos.directives.wp_btn', [])
//  .directive('wpBtnLg', ['TemplateService','$animate', function (TemplateService, $animate) {
//    var tpKey = 'wp-directive-wpBtnLg';
//    var tpValue = '<div class="wp-btn-block wp-btn-lg"><div class="text"><div class="overflow-hidden-text wp-transclude-placehoder"></div></div></div>';
//    TemplateService.registerTemplate(tpKey, tpValue);
//    return {
//      restrict: 'EA',
//      transclude: true,
//      template: '<div></div>',
//      replace: true,
//      link: function (scope, element, attrs, ctrl, $transclude) {
//        var linkFn = TemplateService.getLinkFn(tpKey);
//        linkFn(scope, function(clone){
//          var container = $('.wp-transclude-placehoder', clone);
//          element.addClass(clone.attr('class'))
//          $animate.enter(clone.contents(), element)
//          $transclude(function(contents){
//            container.empty();
//            container.append(contents);
//          })
//        });
//      }
//    }
//  }]).directive('wpBtnMd', ['TemplateService','$animate', function (TemplateService, $animate) {
//  var tpKey = 'wp-directive-wpBtnMd';
//  var tpValue = '<div class="wp-btn-block wp-btn-md"><div class="text"><div class="overflow-hidden-text wp-transclude-placehoder" ></div></div></div>';
//  TemplateService.registerTemplate(tpKey, tpValue);
//  return {
//    restrict: 'EA',
//    transclude: true,
//    template: '<div></div>',
//    replace: true,
//    link: function (scope, element, attrs, ctrl, $transclude) {
//      var linkFn = TemplateService.getLinkFn(tpKey);
//      linkFn(scope, function(clone){
//        var container = $('.wp-transclude-placehoder', clone);
//        element.addClass(clone.attr('class'))
//        $animate.enter(clone.contents(), element)
//        $transclude(function(contents){
//          container.empty();
//          container.append(contents);
//        })
//      });
//    }
//  }
//}]).directive('wpBtn', ['TemplateService','$animate', 'WpNgUtils', function (TemplateService, $animate, WpNgUtils) {
//  var tpKey = 'wp-directive-wpBtn';
//  var tpValue = '<div class="wp-btn-block wp-btn"><div class="text"><div class="overflow-hidden-text wp-transclude-placehoder"></div></div></div>';
//  TemplateService.registerTemplate(tpKey, tpValue);
//  return {
//    restrict: 'EA',
//    transclude: true,
//    template: '<div></div>',
//    replace: true,
//    link: function (scope, element, attrs, ctrl, $transclude) {
//      var linkFn = TemplateService.getLinkFn(tpKey);
//      linkFn(scope, function(clone){
//        var container = $('.wp-transclude-placehoder', clone);
//        element.addClass(clone.attr('class'))
//        $animate.enter(clone.contents(), element)
//        $transclude(function(contents){
//          container.empty();
//          container.append(contents);
//        })
//      });
//    }
//  }
//}]).directive('wpBtnSm', ['TemplateService','$animate', function (TemplateService, $animate) {
//  var tpKey = 'wp-directive-wpBtnSm';
//  var tpValue = '<div class="wp-btn-block wp-btn-sm"><div class="text"><div class="overflow-hidden-text wp-transclude-placehoder"></div></div></div>';
//  TemplateService.registerTemplate(tpKey, tpValue);
//  return {
//    restrict: 'EA',
//    transclude: true,
//    template: '<div></div>',
//    replace: true,
//    link: function (scope, element, attrs, ctrl, $transclude) {
//      var linkFn = TemplateService.getLinkFn(tpKey);
//      linkFn(scope, function(clone){
//        var container = $('.wp-transclude-placehoder', clone);
//        element.addClass(clone.attr('class'))
//        $animate.enter(clone.contents(), element)
//        $transclude(function(contents){
//          container.empty();
//          container.append(contents);
//        })
//      });
//    }
//  }
//}]).directive('wpBtnXs', ['TemplateService', '$animate',function (TemplateService, $animate){
//  var tpKey = 'wp-directive-wpBtnXs';
//  var tpValue = '<div class="wp-btn-block wp-btn-xs"><div class="text"><div class="overflow-hidden-text wp-transclude-placehoder"></div></div></div>';
//  TemplateService.registerTemplate(tpKey, tpValue);
//  return {
//    restrict: 'EA',
//    transclude: true,
//    template: '<div></div>',
//    replace: true,
//    link: function (scope, element, attrs, ctrl, $transclude) {
//      var linkFn = TemplateService.getLinkFn(tpKey);
//      linkFn(scope, function(clone){
//        var container = $('.wp-transclude-placehoder', clone);
//        element.addClass(clone.attr('class'))
//        $animate.enter(clone.contents(), element)
//        $transclude(function(contents){
//          container.empty();
//          container.append(contents);
//        })
//      });
//    }
//  }
//}]).directive('wpTableBtn', ['TemplateService','$animate', function (TemplateService, $animate) {
//  var tpKey = 'wp-directive-wpTableBtn';
//  var tpValue =
//    '<div class="wp-btn-block wp-btn-table">' +
//      '<div class="text">' +
//        '<div class="table-msg  overflow-hidden-text">' +
//            '<span>{{::table.name}}{{table.guest_num_label}}</span><br />' +
//            '<span>{{table.workflow_state_name}}</span>' +
//        '</div>' +
//        '<div class="order-msg"  ng-show="table.order_amount">' +
//          '<span class="order-amount">{{table.order_amount}}</span>' +
//          '<span class="from-wechat" ng-show="table.is_from_wechat"></span>' +
//        '</div>' +
//      '</div>' +
//    '</div>';
//  TemplateService.registerTemplate(tpKey, tpValue);
//  return {
//    restrict: 'EA',
//    template: '<div></div>',
//    replace: true,
//    scope: {
//      table: "="
//    },
//    link: function (scope, element, attrs) {
//      var linkFn = TemplateService.getLinkFn(tpKey);
//      linkFn(scope, function(clone){
//        element.addClass(clone.attr('class'))
//        $animate.enter(clone.contents(), element)
//      });
//    }
//  }
//}]);
