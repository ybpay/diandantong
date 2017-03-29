WebposModules.add_directive('wp_dragdrop')
angular.module('webpos.directives.wp_dragdrop',[])
  .directive("draggable", function(){
    return {
      scope: {
        dragid: "=",
        dropid: "=",
        droped: "&"
      },
      link: function(scope, element){
              var el = element[0];
              el.draggable = true;

              el.addEventListener('dragstart', function(e){
                e.dataTransfer.effectAllowed = 'move';
                e.dataTransfer.setData('Text', scope.dragid);
                return false;
              }, false);

              var DASH_BORDER = "2px dashed #000"
              var ORIGIN_BORDER = $(el).css("border");
              function add_dashed_border(e){
                e.css("border", DASH_BORDER);
              }
              function remove_dashed_border(e){
                e.css("border", ORIGIN_BORDER);
              }

              el.addEventListener('dragover', function(e){
                e.dataTransfer.dropEffect = 'move';
                // allows us to drop
                if (e.preventDefault){e.preventDefault();}
                add_dashed_border($(this))
                return false;
              }, false);



              el.addEventListener('dragenter', function(e){
                add_dashed_border($(this))
                return false;
              }, false);



              el.addEventListener('dragleave', function(e){
                remove_dashed_border($(this))
                return false;
              }, false)



              el.addEventListener('drop', function(e){
                // stop some redirecting
                if(e.stopPropagation){e.stopPropagation()}
                remove_dashed_border($(this))
                var dragid = e.dataTransfer.getData('Text');
                var fn = scope.droped();
                scope.$apply(function(){
                  fn(dragid, scope.dropid);
                })
                return false;
              }, false)
            }
    }
  })
