WebposModules.add_service('queue_form')
angular.module('webpos.services.queue_form',[]).
  factory('QueueFormService', ['$resource', '$interval', 'WebposObjectAsyncAdapter', '$q',
    function($resource, $interval, WebposObjectAsyncAdapter, $q){
      //var object = window.QueueFormObject;
      //var enable = (object !== undefined);
      var object = WebposObjectAsyncAdapter.create({
        obtain_service: function(){
          return window.QueueFormObject;
        }
      });

      var notifys = {};
      function has_object(){
        return object.has_object()
      }

      function show() {
        return object.if_enable(function () {
          return object.show();
        });
      }
      function hide() {
        return object.if_enable(function () {
          return object.hide();
        });
      }

      function set_image_interval(interval){
        return object.if_enable(function () {
          return object.set_image_interval(interval);
        });
      }
      function get_images_path() {
        return object.if_enable(function () {
          return object.get_images_path();
        });
      }
      function set_images_path(path){
        return object.if_enable(function () {
          return object.set_images_path(path);
        });
      }

      function set_queue_name(index, name) {
        return object.if_enable(function () {
          return object.set_queue_name(index, name);
        });
      }
      function set_queue_head(index, head) {
        return object.if_enable(function () {
          return object.set_queue_head(index, head);
        });
      }

      function set_queue_length(index, length){
        return object.if_enable(function () {
          return object.set_queue_length(index, length);
        });
      }

      function set_queue_info(index, name, head, length){
        return object.if_enable(function () {
          return object.set_queue_info(index, name, head, length);
        });
      }

      function clear_queue_info(index){
        return object.if_enable(function(){
          return object.clear_queue_info(index);
        });
      }

      function set_label_text(index, text){
        return object.if_enable(function(){
          return object.set_label_text(index, text);
        })
      }
      function set_label_font_size(index, size){
        return object.if_enable(function(){
          return object.set_label_font_size(index, size);
        });
      }
      function set_label_color(index, color) {
        return object.if_enable(function () {
          return object.set_label_color(index, color);
        });
      }

      function get_queue_name_size(){
        return object.if_enable(function(){
          return object.get_queue_name_size();
        });
      }
      function set_queue_name_size(size){
        return object.if_enable(function () {
          return object.set_queue_name_size(size);
        });
      }
      function get_queue_head_size(){
        return object.if_enable(function () {
          return object.get_queue_head_size();
        })
      }
      function set_queue_head_size(size){
        return object.if_enable(function(){
          return object.set_queue_head_size(size)
        });
      }
      function get_queue_title_size(){
        return object.if_enable(function(){
          return object.get_queue_title_size()
        })
      }
      function set_queue_title_size(size){
        return object.if_enable(function(){
          return object.set_queue_title_size(size);
        });
      }
      function get_queue_form_enable(){
        return object.if_enable(function(){
          object.get_queue_form_enable()
        });
      }
      function set_queue_form_enable(e){
        return object.if_enable(function(){
          return object.set_queue_form_enable(e);
        });
      }

      function set_queue_names(queues){
        var promises = []
        angular.forEach(queues, function(queue){
          var index = queues.indexOf(queue)
          if(index < 3){
            var promise = set_queue_name(index, queue.name + '(' + queue.guest_number_interval_str + ')')
            promises.push(promise)
          }
        })
        return $q.all(promises)
      }

      function set_notify(queue_setting, guest_queue, queue_states){
        notifys['' + queue_setting.id] = guest_queue.guest_no;
        set_queue_states(queue_states);
      }

      function set_queue_states(queue_states){
        var promises = []
        angular.forEach(queue_states, function(queue_state){
           var index = queue_states.indexOf(queue_state)
           if(index < 3){
              if(notifys['' + queue_state.id] == queue_state.head){
                promises.push(set_queue_head(index, queue_state.head))
              }else{
                promises.push(set_queue_head(index, queue_state.front))
              }
              promises.push(set_queue_length(index, queue_state.count))
           }
        })
        return $q.all(promises)
      }

      // video
      function can_set_video(){
        return $q(function(resolve, reject){
          if (object.get_videos_path) {
            object.get_videos_path().then(function () {
              resolve(true)
            }).catch(function () {
              resolve(false)
            })
          }else{
            resolve(false)
          }
        });
      }

      function get_videos_path(){
        return object.if_enable(function(){
          return object.get_videos_path();
        });
      }
      function set_videos_path(path){
        return object.if_enable(function(){
          return object.set_videos_path(path);
        });
      }
      function get_video_volume(){
        return object.if_enable(function(){
          return object.get_video_volume();
        });
      }
      function set_video_volume(volume){
        return object.if_enable(function(){
          return object.set_video_volume(volume);
        });
      }
      function get_mode(){
        return object.if_enable(function(){
          return object.get_mode()
        });
      }
      function set_mode(model){
        return object.if_enable(function(){
          return object.set_mode(model);
        });
      }

      var red_color = "#f00"
      var black_color = "#000"
      var normal_color = "#0f0"
      var flicker_actions = [null, null, null]
      var next_color = [red_color, red_color, red_color];
      var flicker_end_actions = [null, null, null]

      // TODO: 怎么改造成异步?
      function flick(index){
        return object.if_enable(function(){
          var color_index;
          if(index == 0){
            color_index = 4
          }else if(index == 1){
            color_index = 7
          }else if(index == 2){
            color_index = 10
          }else{
            return
          }
          if (angular.isDefined(flicker_actions[index])) {
            $interval.cancel(flicker_actions[index]);
            if(angular.isDefined(flicker_end_actions[index])){
              $interval.cancel(flicker_end_actions[index]);
            }
            flicker_actions[index] = undefined;
            next_color[index] = red_color;
            set_label_color(color_index, normal_color)
          }
          set_label_color(color_index, red_color)
          flicker_actions[index] = $interval(function(){
            next_color[index] = (next_color[index] == red_color ? black_color : red_color)
            set_label_color(color_index, next_color[index])
          }, 500, 10, false)
          flicker_end_actions[index] = $interval(function(){
            set_label_color(color_index, normal_color)
          }, 5100, 1, false)

        });
      }

      return window.QueueFormService = {
        has_object: has_object,
        show:show,
        hide:hide,
        set_notify: set_notify,
        get_images_path: get_images_path,
        set_images_path: set_images_path,
        set_queue_names:set_queue_names,
        set_queue_states: set_queue_states,
        get_queue_name_size: get_queue_name_size,
        set_queue_name_size: set_queue_name_size,
        get_queue_head_size: get_queue_head_size,
        set_queue_head_size: set_queue_head_size,
        get_queue_title_size: get_queue_title_size,
        set_queue_title_size: set_queue_title_size,
        get_queue_form_enable: get_queue_form_enable,
        set_queue_form_enable: set_queue_form_enable,
        flick: flick,
        can_set_video: can_set_video,
        get_videos_path: get_videos_path,
        set_videos_path: set_videos_path,
        get_video_volume: get_video_volume,
        set_video_volume: set_video_volume,
        get_mode: get_mode,
        set_mode: set_mode,
      }
    }]);
