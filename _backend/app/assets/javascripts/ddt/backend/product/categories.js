$(function(){
  $('.dd.categories').nestable({
    maxDepth: 2,
    onDragFinished: function(currentNode, parentNode){
      if(!parentNode){
        parentNode = $('.dd.categories')
      }
      var base_url = $('.dd.categories').data("base-url")
      var current_node_id = $(currentNode).data("id")
      var parent_node_id = $(parentNode).data("id")
      parent_node_id = parent_node_id ? parent_node_id : null
      var position = $("> ol > li", parentNode).index(currentNode)
      $.ajax({
        url: base_url + "/" + current_node_id,
        type: "PUT",
        dateType: "script",
        data:{
          category:{
            parent_id: parent_node_id
          },
          position: position + 1
        }
      })
    }
  })

})