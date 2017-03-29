
function alert_branch_choose(link){
  var path = link;
  if(!link){
    var branch_scope_exp = /\/branches\/\d+/;
    var pathname = window.location.pathname;
    if(pathname.match(branch_scope_exp)){
      path = pathname.replace(branch_scope_exp, '/branches/current')
    }else{
      shop_path = pathname.match(/\/backend\/shops\/\w+/)[0]
      path = shop_path + '/branches/current'
    }

  }
  var branches = JSON.parse($('.managed-branches-data').attr("data"));
  if(branches.length == 1){
    window.location.href = path.replace('current', branches[0].id);
    return
  }
  var render_branches = function(branches, search_key){
    var template = $('#branch_template').html();
    var result = "";
    $.each(branches, function(index, branch){
      if(!search_key || branch.name.includes(search_key)){
        var template_dup = template;
        var branch_link = path.replace('current', branch.id)
        result += template_dup.replace(/@link/, branch_link).replace(/@name/, branch.name)
      }
    })
    return result;
  }

  var inp = '<input id="search_key" type= "text" class="form-control" placeholder="输入门店名称查询">'
  var html = '<div class="panel" id="shop_panel">' + render_branches(branches) + "</div>"
  bootbox.hideAll();
  bootbox.dialog({
    message: inp+html,
    title: "选择门店"
  });

  setTimeout(function(){
    $('#search_key').bind("input propertychange",function(value){
      var html = render_branches(branches, $('#search_key').val())
      $("#shop_panel").html(html)
    })
  }, 200)
}



function choose_branch(link){
  bootbox.hideAll();
  return true;
}
