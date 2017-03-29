$(function () {
    // Initialize the jQuery File Upload widget:
    $('#fileupload').fileupload({
      maxNumberOfFiles: 5,
      maxFileSize: 500000,
      acceptFileTypes: '/^image\/(gif|jpeg|png)$/',
      previewSourceFileTypes: '/^image\/(gif|jpeg|png)$/',
    })
    //
    // Load existing files:
    load_existing_product_image_files()
});

function load_existing_product_image_files(){
  if($('#fileupload').length > 0){
    $.getJSON($('#fileupload').prop('action'), function (files) {
      var fu = $('#fileupload').data('blueimp-fileupload'),
        template;
      fu._adjustMaxNumberOfFiles(-files.length);
      $('#fileupload .files').empty()
      template = fu._renderDownload(files)
        .appendTo($('#fileupload .files'));
      // Force reflow:
      fu._reflow = fu._transition && template.length &&
        template[0].offsetWidth;
      template.addClass('in');
      $('#loading').remove();
    });
  }
}
