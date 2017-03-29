

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
  var html = "<div class='panel'>"
  $.each(branches, function(index, branch){
    var template = $('#branch_template').html();
    var branch_link = path.replace('current', branch.id)
    html += template.replace(/@link/, branch_link).replace(/@name/, branch.name)
  })
  html += "</div>"
  bootbox.hideAll();
  // bootbox.dialog({
  //   message: html,
  //   title: "切换门店"
  // });
  bootbox.alert(html)
}

function choose_branch(link){
  bootbox.hideAll();
  return true;
}
