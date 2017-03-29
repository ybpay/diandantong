$(function(){
  $('.dd.reasons').nestable({
    maxDepth: 1,
    onDragFinished: function(currentNode, parentNode){
      if(!parentNode){
        parentNode = $('.dd.reasons')
      }
      var base_url = $('.dd.reasons').data("base-url")
      var current_node_id = $(currentNode).data("id")
      var parent_node_id = $(parentNode).data("id")
      parent_node_id = parent_node_id ? parent_node_id : null
      var position = $("> ol > li", parentNode).index(currentNode)
      $.ajax({
        url: base_url + "/" + current_node_id,
        type: "PUT",
        dateType: "script",
        data:{
          gift_reason:{ position: position + 1 },
          subtract_reason:{ position: position + 1 },
          item_note: { position: position + 1 },
          position: position + 1
        }
      })
    }
  })

})