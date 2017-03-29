$(document).ready(function() {
  $("#upload_products").dialog({
    autoOpen: false,
    width: 350
  });
  $("#upload_file").click(function(event) {
    event.preventDefault(event);
    $("#upload_products").dialog("open");
  });
});
