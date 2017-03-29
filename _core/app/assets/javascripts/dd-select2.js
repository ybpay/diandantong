'use strict';
function init_ddb_select2(){
  $('.ddb-select2').each(function(){
    var url = $(this).data('url');
    var search_column = $(this).data('column')
    var placeholder = $(this).data('placeholder');
    var saved = eval($(this).data('saved'));
    var multiple = !$(this).data('single');
    var local_datas = eval($(this).data('local-datas'));
    var selected_id = $(this).data('selected-id');
    var search_conditions = $(this).data('search-conditions')

    var use_as = $(this).data('useas'); /* select , tag , local_select*/

    // default setting
    if(search_column==null){ search_column = "name_cont" }
    if(search_conditions==null){ search_conditions = {}}
    if(use_as==null){ use_as = "select" }



    function select2_url(){
      try{ return dynamic_select2_url();}catch(e){ return url}
    }

    // common ajax configuration
    var ajax_conf = {
      url: select2_url,
      quietMillis: 200,
      datatype: 'json',
      data: function (term) {
        search_column.split(" ").forEach(function(c){
          search_conditions[c] = term
        })
        return { q: search_conditions };
      },
      results: function (data) {
        return {
          results: data
        };
      }
    }
    // common init selection
    function init_selection(element, callback){
      if(multiple){
        if (saved && saved.length > 0) {
          callback(saved);
        }
      }else{
        if(saved){ callback(saved); }
      }
    }

    function init_as_select(domobj){
      $(domobj).select2({
        placeholder: placeholder,
        multiple: multiple,
        initSelection: init_selection,
        ajax: ajax_conf,
        formatResult: function (item) {
          if(item.error){
            return "<span class='label label-danger'>"+item.error+"</span>"
          }else{
            return item.name
          }
        },
        formatSelection: function (item) {
          return item.name;
        }
      }).select2('val', [])
      // https://github.com/select2/select2/issues/2086
    }

    function init_as_tag(domobj){
      function format(item){
        return "<span class=''><i class='fa fa-tag'></li> "+item.text+" </span>";
      }

      $(domobj).select2({
        placeholder: placeholder,
        tags: true,
        maximumInputLength: 10,
        tokenSeparators: [",", "，"," "],
        formatResult: format,
        formatSelection: format,
        escapeMarkup: function (m) { return m; },
        createSearchChoice: function (term) {
            return {
                id: $.trim(term),
                text: $.trim(term)
            };
        },
        ajax: ajax_conf,
        initSelection: init_selection
      });
    }

    function init_as_local_select(domobj){
      if(local_datas){
        local_datas.forEach(function(item){item.text = item.name})
        if(selected_id){
          local_datas.forEach(function(item){
            if(item.id == selected_id){
              $(domobj).html('<option selected="selected" value="'+item.id+'">'+item.text+'</option>')
            }
          })
        }
        $(domobj).select2({
          multiple: multiple,
          placeholder: placeholder,
          data: local_datas
        })
      }
    }

    if(use_as == "select"){
      init_as_select(this);
    }else if(use_as == "tag"){
      init_as_tag(this);
    }else if(use_as == "local_select"){
      init_as_local_select(this);
    }

  })
}

$(document).ready(function () {
  init_ddb_select2();
});
