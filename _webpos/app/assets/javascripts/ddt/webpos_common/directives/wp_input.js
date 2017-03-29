WebposModules.add_directive('wp_input')
var WpInput = angular.module('webpos.directives.wp_input', [])
WpInput.directive('wpInput', ['$rootScope',
    function ($rootScope) {
    return {
      restrict: 'EA',
      scope:{
        input_model: '=inputModel',
        input_focus: '=inputFocus',
        auto_clear: '@autoClear',
        input_type: '@inputType',
        input_size: '@inputSize',
        input_restrict: '@inputRestrict',
        placeholder: '@placeholder'
      },
      replace: true,
      template: '<div>'+
                  '<div class="no-password wp-form-input-keypad {{::size_class()}}"'+
                    ' ng-show="no_password()"'+
                    ' data-ng-model="input_model" '+
                    ' data-ng-keypad-input="{{::input_type}}"'+
                    ' ng-keypad-restrict="{{::input_restrict}}">'+
                    '<span>{{input_model}}</span>'+
                  '</div>' +
                  '<div class="password wp-form-input-keypad {{::size_class()}}"'+
                    ' ng-show="password()"'+
                    ' data-ng-model="input_model" '+
                    ' data-ng-keypad-input="text"'+
                    ' ng-keypad-restrict="{{::input_restrict}}">'+
                    '<span>{{input_model | password}}</span>'+
                  '</div>'+
                  '<div class="normal-input wp-form-input {{::size_class()}} wp-form-input-{{::normal_input_type()}}"'+
                      ' ng-show="!enable_jvk">'+
                    '<input type="{{::normal_input_type()}}" ng-model="input_model" placeholder="{{::placeholder}}">'+
                  '</div>'+
                '</div>',
      link: function(scope, element, attrs){
        scope.enable_jvk = $rootScope.enable_jvk
        var clear_watch_enable_jvk = $rootScope.$watch('enable_jvk', function(enable_jvk){
          scope.enable_jvk = enable_jvk
        })

        scope.no_password = function(){
          return scope.enable_jvk && !scope.is_password();
        }

        scope.password = function(){
          return scope.enable_jvk && scope.is_password();
        }

        var clear_watch_input_focus = scope.$watch('input_focus', function(input_focus){
          if(input_focus){
            if(scope.auto_clear){ scope.input_model = null;}
            if(scope.password()){ element.children('.password').trigger('click.ngKeypadInput')}
            if(scope.no_password()) { element.children('.no-password').trigger('click.ngKeypadInput') }
          }
        });

        scope.$on("$destroy", function(){
          clear_watch_enable_jvk()
          clear_watch_input_focus()
        })


        scope.size_class = function(){
          if(scope.input_size){
            return "wp-form-input-" + scope.input_size
          }
        }

        scope.is_password = function(){
          return scope.input_type === 'password'
        }

        scope.normal_input_type = function(){
          return scope.input_type === 'number' ? 'text' : scope.input_type
        }

      }
    }
  }])
WpInput.directive('wpSearchInput', ['$rootScope',
    function ($rootScope) {
    return {
      restrict: 'EA',
      scope:{
        input_model: '=inputModel',
        placeholder: '@placeholder'
      },
      replace: true,
      template: '<div class="wp-search-input">'+
                  '<div class="keypad-input"'+
                    ' ng-show="enable_jvk"'+
                    ' data-ng-model="input_model" '+
                    ' data-ng-keypad-input="text">'+
                    '<span>{{input_model}}</span>'+
                  '</div>' +
                  '<div class="normal-input"'+
                      ' ng-show="!enable_jvk">'+
                    '<input type="text" ng-model="input_model" placeholder="{{::placeholder}}">'+
                  '</div>'+
                  '<i class="fa fa-search"></i>'+
                '</div>',
      link: function(scope, element, attrs){
        scope.enable_jvk = $rootScope.enable_jvk
        var clear_watch_enable_jvk = $rootScope.$watch('enable_jvk', function(enable_jvk){
          scope.enable_jvk = enable_jvk
        })
        scope.$on("$destroy", function(){
          clear_watch_enable_jvk()
        })
      }
    }
  }])
WpInput.directive('wpMenuSearchInput', ['$rootScope',
    function ($rootScope) {
    return {
      restrict: 'EA',
      scope:{
        input_model: '=inputModel',
        placeholder: '@placeholder'
      },
      replace: true,
      template: '<div class="wp-menu-search-input">'+
                  '<div class="keypad-input"'+
                    ' ng-show="enable_jvk"'+
                    ' data-ng-model="input_model" '+
                    ' data-ng-keypad-input="text">'+
                    '<span>{{input_model}}</span>'+
                  '</div>' +
                  '<div class="normal-input"'+
                      ' ng-show="!enable_jvk">'+
                    '<input type="text" ng-model="input_model" placeholder="{{::placeholder}}">'+
                  '</div>'+
                  '<i class="fa fa-search"></i>'+
                '</div>',
      link: function(scope, element, attrs){
        scope.enable_jvk = $rootScope.enable_jvk
        var clear_watch_enable_jvk = $rootScope.$watch('enable_jvk', function(enable_jvk){
          scope.enable_jvk = enable_jvk
        })
        scope.$on("$destroy", function(){
          clear_watch_enable_jvk()
        })
      }
    }
  }])
WpInput.directive('wpAlphaSearchInput', ['$rootScope',
    function ($rootScope) {
    return {
      restrict: 'EA',
      scope:{
        input_model: '=inputModel',
        placeholder: '@placeholder'
      },
      replace: true,
      template: '<div class="wp-search-input">'+
                  '<div class="keypad-input"'+
                    ' ng-show="enable_jvk"'+
                    ' data-ng-model="input_model" '+
                    ' data-ng-keypad-input="alpha">'+
                    '<span>{{input_model}}</span>'+
                  '</div>' +
                  '<div class="normal-input"'+
                      ' ng-show="!enable_jvk">'+
                    '<input type="text" ng-model="input_model" placeholder="{{::placeholder}}">'+
                  '</div>'+
                  '<i class="fa fa-search"></i>'+
                '</div>',
      link: function(scope, element, attrs){
        scope.enable_jvk = $rootScope.enable_jvk
        var clear_watch_enable_jvk = $rootScope.$watch('enable_jvk', function(enable_jvk){
          scope.enable_jvk = enable_jvk
        })
        scope.$on("$destroy", function(){
          clear_watch_enable_jvk()
        })
      }
    }
  }])
WpInput.directive('wpDatetimeInput', [function () {
    return {
      restrict: 'EA',
      replace: true,
      scope:{
        input_model: "=inputModel",
        input_type: '@inputType',
        placeholder: '@placeholder'
      },
      template: '<div class="wp-datetime-input {{input_type}}">'+
                  '<input type="text" ng-model="input_model" placeholder="{{placeholder}}">'+
                  '<span class="input-group-addon" ng-click="toggle()"><span class="fa {{icon_class}}"></span></span>' +
                '</div>',
      link: function(scope, element, attrs){
        var pickDate = true
        var pickTime = true
        var format = 'YYYY-MM-DD HH:mm'
        switch(scope.input_type){
          case "datetime":
            pickDate = true
            pickTime = true
            format = 'YYYY-MM-DD HH:mm'
            break;
          case "date":
            pickDate = true
            pickTime = false
            format = 'YYYY-MM-DD'
            break;
          case "time":
            pickDate = false
            pickTime = true
            format = 'HH:mm'
            break;
        }
        scope.icon_class = pickDate ? 'fa-calendar' : 'fa-clock-o'

        $("input", element).datetimepicker({
          pickDate: pickDate ,
          pickTime: pickTime,
          format: format
        });


        var datetime_picker = $("input", element).data("DateTimePicker")
        scope.toggle = function(){
          if(datetime_picker.widget.is(":visible")){
            $("input", element).blur()
          }else{
            $("input", element).focus()
          }
        }
      }
    }
  }])
