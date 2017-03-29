Ddt.module('ddt_app.directives.bg_image', []).directive('bgImage', function () {
  return {
    link: function (scope, el, attrs) {
      var url = attrs.bgImage;
      if(url){
        el.css({
            'background': '-moz-linear-gradient(right, rgba(255,255,255,0) 0%, rgba(255,255,255,0.99) 50%, rgba(255,255,255,1) 100%),url('+url+')',
            'background': ' -o-linear-gradient(right, rgba(255,255,255,0) 0%, rgba(255,255,255,0.99) 50%, rgba(255,255,255,1) 100%),url('+url+')',
            'background':  '-webkit-linear-gradient(right, rgba(255,255,255,0) 0%, rgba(255,255,255,0.99) 50%, rgba(255,255,255,1) 100%),url('+url+')',
            'background-size': 'contain',
            'background-repeat': 'no-repeat',
            'background-position': 'right'
        });
      }
    }
  }
});
