Ddt.module('ddt_app.directives.swiper_slider', [])
.directive('ngSwiperSlider', function () {
  return {
    restrict: 'EA',
    scope: {
      sliders: '=',
      clickSlider: '=ngClick'
    },
    // template: '<div class="swiper-container"><div class="swiper-wrapper"><div class="swiper-slide" ng-repeat="s in sliders" ng-click="clickSlider(s)"><img src="{{s.img}}"/></div></div><div class="my-pagination"></div></div>',
    link: function(scope, element, attrs) {

      scope.$watch('sliders', function(sliders){

        var html =  '<div class="swiper-container"><div class="swiper-wrapper">';
        if(sliders){
          for(var i =0;i < sliders.length; i++){
            var slider = sliders[i];
            html += '<div class="swiper-slide">';
            if(slider.url){
              html += '<a href="'+slider.url+'">';
            }
            html += '<img src="'+slider.img+'"/>';
            if(slider.url){
              html += '</a>';
            }
            html += '</div>';
          }
        }

        html += "</div>"
        html += '<div class="my-pagination"></div>'
        html += '</div>'
        var e = element[0]
        e.innerHTML = html;
        var mySwiper = $(e).find('.swiper-container')
        mySwiper.swiper({
          //Your options here:
          mode:'horizontal',
          loop: true,
          autoplay: 3000,
          speed: 1000,
          roundLengths: true,
          pagination: '.my-pagination',
          paginationClickable: true,
          // calculateHeight: true,
          visibilityFullFit: true
          //etc..
        });
      });

      // scope.$observe(scope.sliders, function(value){
      //   console.log(value);
      // });
    }
  };
})
.directive('ngSwiperTab', function(){
  return {
    restrict: 'EA',
    transclude: true,
    template: '<div class="swiper-container tab-slider" ><div class="swiper-wrapper" ng-transclude></div><div class="swiper-pagination"></div></div>',
    link: function(scope, element, attrs){
      setTimeout(function(){
        var mySwiper = $(element[0]).find('.swiper-container')
        mySwiper.swiper({
          mode: 'horizontal',
          loop: true,
          pagination: '.swiper-pagination',
          paginationClickable: true,
          visibilityFullFit: true,
          onSlideClick: function (swiper, event) {
            var target = $(event.target)
            var key = target.attr('tab-slider-key');
            if(!key){
              key = target.parents('[tab-slider-key]').attr('tab-slider-key')
            }
            angular.element(swiper.clickedSlide).scope().click_tab_slider(key);
          }
        })
      }, 0)
    }
  }
})
