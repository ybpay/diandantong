(function () {
  var rootElem = $('.extended-form-fastfood-cart')
  if (rootElem) {
    rootElem.removeClass("hide");
    var data = rootElem.data();
    var images = data.images
    var imageWrapper = $('.image-wrapper', rootElem);
    var intervalInSeconds = data.interval

    for (var i = 0; i < images.length; ++i) {
      parent.window.postMessage({
        type: "webpos:iframe:getDataUri",
        arguments: [images[i]]
      }, '*')
    }

    var ShowImageLoop = {
      interval: intervalInSeconds * 1000,
      index: null,
      inthl: null,

      can_show: function () {
        return $(".image", imageWrapper).length > 0;
      },

      show: function () {
        var This = this;
        if (This.can_show()) {
          var tags = $(".image", imageWrapper);
          // asset index
          if (!This.index || !tags[This.index]) {
            This.index = 0;
          }

          // update visible
          tags.addClass("hide");
          $(tags[This.index]).removeClass("hide");

          // update index
          This.index += 1;
          This.inthl = null;
        }
      },

      loop: function () {
        var This = this;
        if (This.inthl) {
          clearTimeout(This.inthl);
        }
        if (!This.index) {
          This.show();
        }
        This.inthl = setTimeout(function () {
          This.show();
          This.loop();
        }, This.interval);
      }
    };

    window.addEventListener("message", function (event) {
      var data = event.data
      switch (data.type) {
        case 'webpos:iframe:getDataUri':
        {
          $("<img>")
            .attr("src", data.result)
            .attr("class", "image hide")
            //.css("display", "none")
            .appendTo(imageWrapper);
          ShowImageLoop.loop();
          break;
        }
        case 'webpos:fastfood:updateCart':
        {
          $('.ff-item-container').html(data.html)
          break;
        }
      }
    });
  }
})();
