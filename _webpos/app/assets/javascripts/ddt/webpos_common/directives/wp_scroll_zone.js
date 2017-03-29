//该标签模块用于支持某个区域的滚动，兼容性较好
WebposModules.add_directive('wp_scroll_zone')
angular.module('webpos.directives.wp_scroll_zone', [])
  .directive('wpScrollZone', ['$timeout',
    function ($timeout) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs){
        $(element[0]).addClass('fill-parent-wrapper').css({ height: "100%"})
        $(element[0]).children(":not(.no-scroll)").wrapAll("<div class='fill-parent'></div>")
        var first_child = $(element[0]).children().first()
        first_child.addClass("scroll-wrapper")
        first_child.children(":not(.no-scroll)").wrapAll("<div></div>")
        if(attrs.hasOwnProperty('scrollBtns')){
          $(element[0]).append('<div class="scroll-btn-up" onclick="scroll_up(this)"><i class="fa fa-chevron-up"></i></div><div class="scroll-btn-down" onclick="scroll_down(this)"><i class="fa fa-chevron-down"></i></div>')
        }
        var scroll_element = first_child[0];
        var scroll = null;
        $timeout(update_scroll_zone, 500);
        function update_scroll_zone(){
          if(scroll_element){
            scroll = new IScroll(scroll_element, {
              mouseWheel: true,
              scrollbars: false,
              bounce: false,
              click: true,
              tap: false
            });
            $(scroll_element).data("scroll", scroll);
          }
        }

        function get_height(){
          return $(scroll_element).height()
        }

        function get_children_height(){
          return $($(scroll_element).children()[0]).height()
        }

        function refresh(){
          if(scroll){
            scroll.refresh();
          }
        }

        function fire_refresh(){
          /*https://github.com/cubiq/iscroll#mastering-the-refresh-method*/
          $timeout(refresh, 100)
          $timeout(refresh, 1000)
          $timeout(refresh, 3000)
          $timeout(refresh, 6000)
          $timeout(refresh, 8000)
        }

        var clear_watch_get_height = scope.$watch(get_height, fire_refresh)
        var clear_get_children_height = scope.$watch(get_children_height, fire_refresh)
        scope.$on("$destroy", function(){
          scroll_element = undefined;
          if(scroll){ scroll.destroy(); scroll = undefined; }
          clear_watch_get_height()
          clear_get_children_height()
        })

        //element.children().css("overflow", "visible")
        element.children().first().css("-webkit-transform", "translateZ(0px)")
      }
    }
  }]);
