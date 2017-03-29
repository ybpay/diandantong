/**
 * @overview
 * @copyright 2013 Tommy Rochette http://trochette.github.com/
 * @author Tommy Rochette
 * @version 0.0.1
 *
 * @license MIT
 */
(function () {
    "use strict";

    var touchMode = localStorage.ddb_key_pad_touch_mode;
    switch(touchMode){
      case 'true': touchMode = true; break;
      case 'false': touchMode = false; break;
      default: touchMode = undefined; break;
    }

    /**
     * @Class
     */
    window.Key = function ($scope, $element, $attrs) {

        var body = $('body');

        /**
         * Initialize Key to default settings
         */
        function init() {
            if ("ontouchstart" in document.documentElement){
                $element.bind('touchstart.ngKey', keyPressedOnTouch);
                body.bind('touchend.ngKey', keyDepressedOnTouch);
            }
            // else {
                $element.bind('mousedown.ngKey', keyPressed);
                body.bind('mouseup.ngKey', keyDepressed);
            // }

            $scope.$on('destroy', destroy);
        };

        function keyPressedOnTouch(event){
          if (touchMode){
            keyPressed(event)
          }
        }

        function keyDepressedOnTouch(event){
          if (touchMode){
            keyDepressed(event)
          }
        }

        /**
         * Triggered when a user press on this element
         *
         * @param event
         */
        function keyPressed(event) {
            if (touchMode == undefined) {
              touchMode = false
              localStorage.ddb_key_pad_touch_mode = false
            }
            $element.addClass('pressed');
            event.preventDefault();
            event.stopImmediatePropagation();
            $scope.$emit(Key.PRESSED, $attrs.ngKey);
        }


        /**
         * Triggered when a user stop pressing this element
         *
         * @param event
         */
        function keyDepressed(event) {
          if (touchMode == undefined){
            touchMode = true; // 如果没经过 keyPressed 到这里，设置 touchMode 为真
            localStorage.ddb_key_pad_touch_mode = true
          }
          $element.removeClass('pressed');
        }

        /**
         * Cleanup all listeners before destroying this directive.
         */
        function destroy() {
            $element.unbind('touchstart.ngKey', keyPressed);
            body.unbind('touchend.ngKey', keyDepressed);
            $element.unbind('mousedown.ngKey', keyPressed);
            body.unbind('mouseup.ngKey', keyDepressed);
        }


        init();
    };

    /**
     * @Event
     */
    Key.PRESSED = "Key.PRESSED";

    angular.module('ngKeypad', [])
        .directive('ngKey', function () {
            return {
                restrict: 'A',
                link: function ($scope, $element, $attrs) {
                    new Key($scope, $element, $attrs);
                }
            };
        });
})();