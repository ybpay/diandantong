'use strict';
/*
  <input type="checkbox" id="batch_op_select_all" data-model="order" data-token="csrf-token-str"/>
  <a href="aaa/bbb" class="batch_op_action" confirmtxt="confirm ?" data-remote="true" data-method="post">batchopname</a>
*/
function init_batch_operation(){
  var _batch_op_select_all = $("#batch_op_select_all")
  if(_batch_op_select_all.length == [0]){return;}
  var _batch_op_model = _batch_op_select_all.data('model');
  var _form_auth_token = _batch_op_select_all.data('token');

  //-----select all------
  _batch_op_select_all.off("change");
  _batch_op_select_all.on("change", function(){
    var matcher_str = "input[type=checkbox][name='"+_batch_op_model+"[id][]']"
    var checked = false;
    if($(this).is(":checked")){ checked = true; }
    $.each($(matcher_str), function(idx, node){ $(node).prop("checked", checked) })
  });

  //-----batch action-----
  $(".batch_op_action").each(function(){
    $(this).off("click");
    $(this).on("click", function(event){
      event.preventDefault(event);
      var _batch_op_confirmtxt = $(this).attr("confirmtxt");
      if(_batch_op_confirmtxt){
        bootbox.confirm(_batch_op_confirmtxt, function(result){
          if(result){
            batch_op(event);
          }
        })
      }else{
        batch_op(event);
      }
      return false;
    })
  })

  //------------
  var batch_op = function(event){
    event.preventDefault(event);
    var target = $(event.target)
    var form_action = target.attr("href");
    var form_remote = target.attr("data-remote") || false
    var form_method = target.attr("data-method") || "POST"
    var selected_objs = $("input[type=checkbox][name='"+_batch_op_model+"[id][]']:checked");
    if(selected_objs.length > 0){
      var form = create_form(form_action, form_method, form_remote);
      form.appendChild(create_input("authenticity_token",_form_auth_token))
      $.each(selected_objs, function(index, obj){
        form.appendChild(create_input(""+_batch_op_model+"["+_batch_op_model+"_ids][]", obj.value))
      })
      var submit = create_submit();
      form.appendChild(submit)
      document.body.appendChild(form);
      setTimeout(function(){
       $(document).trigger('page:load')
       $(submit).trigger("click")
       document.body.removeChild(form);
       if(form_remote){
         bootbox.alert("操作处理中，请稍等...");
       }
      }, 100)
    }else{
      bootbox.alert("请先选择要操作的对象");
      return false;
    }
  }

  var create_submit = function(){return create_dom("input", ["type"], ["submit"])}
  var create_input  = function(name, value){return create_dom("input", ["type", "name", "value"], ["hidden", name, value])}
  var create_form   = function(action, method, remote){
    if(remote==false){
      return create_dom("form", ["action", "method"], [action, method])
    }else{
      return create_dom("form", ["action", "method", "data-remote"], [action, method, remote])
    }
  }

  var create_dom = function(tagName, attr_names, attr_values){
    var dom = document.createElement(tagName);
    $.each(attr_names, function(index, attr_name){
      dom.setAttribute(attr_name, attr_values[index])
    });
    return dom
  }
}

$(document).ready(function () { init_batch_operation();});
