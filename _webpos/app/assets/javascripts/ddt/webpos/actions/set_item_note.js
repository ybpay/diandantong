
WebposModules.add_action('set_item_note');
angular.module('webpos.actions.set_item_note', []).
  factory('SetItemNoteAction',
    ['$rootScope', '$routeParams', 'ItemNoteService',
    function($rootScope, $routeParams, ItemNoteService){
      function init(){
        var _modal = {};
        _modal.show = false;
        _modal.notes = [];
        _modal.custom_item_note = null;
        _modal.item_notes = [];
        _modal.all_item_notes = [];
        _modal.tags = [];
        _modal.default_tag = {id: -1, name: '默认'};
        _modal.current_tag = null;
        _modal.callback = undefined;

        _modal.change_tag = function(tag){
          this.current_tag = tag;
          this.item_notes = [];
          angular.forEach(this.all_item_notes, function(item_note){
            if(item_note.tag_ids.indexOf(tag.id) != -1){
              _modal.item_notes.push(item_note);
            }
          })
        }

        _modal.init = function(){
          ItemNoteService.query($routeParams.branch_id, function(result){
            _modal.all_item_notes = result.item_notes;
            _modal.tags = result.tags;
            _modal.tags.unshift(_modal.default_tag);
            _modal.change_tag(_modal.default_tag);
          });
        }

        _modal.open = function(note, callback){
          this.notes = [];
          this.custom_item_note = '';
          this.callback = callback;
          this.show = true;
          $rootScope.focus('.item-note-field input');
        }

        _modal.close = function(){
          this.show = false;
        }

        _modal.submit = function(){
          var note = this.custom_item_note || this.notes.join(" ")
          if(this.callback){
            this.callback(note)
          }
          this.close();
        }

        _modal.select = function(item_note){
          this.notes.push(item_note.name)
        }

        _modal.delete_note = function(note){
          var idx = this.notes.indexOf(note);
          this.notes.splice(idx, 1);
        }

        _modal.init();
        $rootScope.item_notes_modal = _modal;

      }

      function dispose(){
        $rootScope.item_notes_modal = undefined
      }
      return {
        init: init,
        dispose: dispose
      }

    }]);
