WebposModules.add_service('item_note')
angular.module('webpos.services.item_note', []).
  factory('ItemNoteService', ['$resource', function($resource){
    var ItemNote = $resource('/branches/:branch_id/item_notes/:id/:action',{},{
      query: { method: 'get', cache: true }
    })

    function query(branch_id, success){
      ItemNote.query({branch_id: branch_id}, success)
    }

    return {
      query: query
    }
  }])
