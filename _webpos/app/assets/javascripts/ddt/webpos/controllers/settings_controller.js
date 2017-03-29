WebposModules.add_controller('settings')
angular.module('webpos.controllers.settings', []).
  controller('settingsController', ['$rootScope', '$scope', 'TtsService','CardReaderService','WirePrinterService','CustomerDisplayService','QueueFormService','ExtendedFormService', 'HotkeyService', 'CashBoxSettingService', 'FastfoodFormService',
    function($rootScope, $scope, TtsService,CardReaderService,WirePrinterService,CustomerDisplayService,QueueFormService,ExtendedFormService, HotkeyService, CashBoxSettingService, FastfoodFormService){
      $scope.settings = [
        { name: '当前打印机',   show: $rootScope.is_cef, key: 'printer'},
        { name: '数字客显设置', show: $rootScope.is_cef, key: 'customer_display' },
        { name: '语音设置',    show: true, key: 'voice' },
        { name: '读卡器设置',   show: true, key: 'card' },
        { name: '快捷键设置', show: true, key: 'hotkey'},
        { name: '钱箱设置', show: true, key: 'cash_box'},
        { name: '排号客显设置', show: $rootScope.is_cef && QueueFormService.has_object(), key: 'queue_form' },
        { name: '快餐客显设置', show: $rootScope.is_cef && FastfoodFormService.has_object(), key: 'fastfood_form'}
        // { name: '收银客显设置', show: $rootScope.is_cef, key: 'extended_form' }
      ]

      setTimeout(function(){
        if($rootScope.active_printer_config){
          //激活 '当前打印机' tab
          $scope.change_active_setting($scope.settings[0])
        }
      },200)

      $scope.change_active_setting = function(setting){
        $scope.active_setting = setting
      }

      if($rootScope.is_cef){
        // webpos有线打印机设置
        $scope.new_cef_version = WirePrinterService.is_new_cef_version()
        if($scope.new_cef_version){
          $scope.printer_setting = {
            //printer_names: WirePrinterService.get_printer_names().split(";"),
            //printer_com_ports: WirePrinterService.get_printer_com_ports().split(";"),
            printer_name: WirePrinterService.get_printer_name(),
            printer_widths: [{name: "58mm", value: 58}, {name: "80mm", value: 80}, {name: "标签", value: 60}],
            printer_width: WirePrinterService.get_printer_width(),
            printer_times: WirePrinterService.get_printer_times(),
            printer_type: WirePrinterService.get_printer_type(),
            is_manual_print: WirePrinterService.is_manual_print(),
            printer_types: [{name: "驱动打印机",value: "driven"},{name: "网口打印机",value: "net"},{name: "串口打印机",value: "com"},{name: "并口打印机",value: "lpt"}],
            printer_net_port: WirePrinterService.get_printer_net_port(),
            printer_com_port: WirePrinterService.get_printer_com_port(),
            printer_baud_rate: WirePrinterService.get_printer_baud_rate(),
            printer_baud_rates: [2400, 4800, 9600, 19200, 38400, 57600, 115200],
            printer_lpt_port: WirePrinterService.get_printer_lpt_port(),
            printer_lpt_ports: ["LPT1", "LPT2", "LPT3"],
            printer_times_collection: [1,2,3,4,5],
            change_printer_type: function(type){
              this.printer_type = type; this.submit();
            },
            change_printer_name: function(name){
              this.printer_name = name; this.submit();
            },
            change_printer_width: function(width){
              this.printer_width = width; this.submit();
            },
            change_printer_net_port: function(net_port){
              this.printer_net_port = net_port; this.submit();
            },
            change_printer_com_port: function(com_port){
              this.printer_com_port = com_port; this.submit();
            },
            change_printer_baud_rate: function(baud_rate){
              this.printer_baud_rate = baud_rate; this.submit();
            },
            change_printer_lpt_port: function(lpt_port){
              this.printer_lpt_port = lpt_port; this.submit();
            },
            change_printer_times: function(times){
              this.printer_times = times; this.submit();
            },
            test: function(){
              if(WirePrinterService.is_config()){
                WirePrinterService.print("<C>测试打印</C>\n<PCN>ddt</PCN>")
              }
            },
            submit: function(){
              if(this.printer_width){
                WirePrinterService.set_printer_info(
                  this.printer_type,
                  this.printer_name,
                  this.printer_width,
                  this.printer_net_port,
                  this.printer_com_port,
                  this.printer_baud_rate,
                  this.printer_lpt_port,
                  parseInt(this.printer_times)
                )
              }
            }
          }
          //printer_names: WirePrinterService.get_printer_names().split(";"),
          //printer_com_ports: WirePrinterService.get_printer_com_ports().split(";"),
          WirePrinterService.get_printer_names().then(function(names){
            $scope.$apply(function(){
              $scope.printer_setting.printer_names = names.split(';')
            });
          });
          WirePrinterService.get_printer_com_ports().then(function(ports){
            $scope.$apply(function(){
              $scope.printer_setting.printer_com_ports = ports.split(';')
            });
          });

          for (var name in $scope.printer_setting) {
            if (name != "get_printer_names" && name != "get_printer_com_ports") {
              var getter = $scope.printer_setting[name]
              if (getter instanceof Promise || (getter.then && getter.catch)) {
                (function () {
                  var theName = name;
                  getter.then(function (value) {
                    $scope.$apply(function () {
                      $scope.printer_setting[theName] = value
                    })
                  });
                })();
              }
            }
          }

          var clear_watch_printer_net_port = $scope.$watch("printer_setting.printer_net_port", function(){
            $scope.printer_setting.submit()
          })
          $scope.$on("$destroy", function(){
            clear_watch_printer_net_port()
          })
        }

        // webpos客显设置
        $scope.customer_display_setting = {
          port_names: ["COM1", "COM2", "COM3"],
          port_name: CustomerDisplayService.get_port_name(),
          baud_rates: [2400, 4800, 9600],
          baud_rate: CustomerDisplayService.get_baud_rate(),
          test: function(){
            CustomerDisplayService.display_data(2, "121.50");
          },
          change_port_name: function(port_name){
            this.port_name = port_name; this.submit();
          },
          change_baud_rate: function(baud_rate){
            this.baud_rate = baud_rate; this.submit();
          },
          submit: function(){
            if(this.port_name && this.baud_rate){
              CustomerDisplayService.set_info(this.port_name, this.baud_rate)
            }
          }
        }

        // 排号客显设置
        if (QueueFormService.has_object()) {
          QueueFormService.can_set_video().then(function (can) {
              $scope.can_set_video = can
              if ($scope.can_set_video) {
                $scope.queue_form_setting = {
                  mode: QueueFormService.get_mode(),
                  videos_path: QueueFormService.get_videos_path(),
                  video_volume: QueueFormService.get_video_volume(),
                  images_path: QueueFormService.get_images_path(),
                  name_size: QueueFormService.get_queue_name_size(),
                  head_size: QueueFormService.get_queue_head_size(),
                  title_size: QueueFormService.get_queue_title_size(),
                  enable: QueueFormService.get_queue_form_enable(),
                  submit: function () {
                    QueueFormService.set_mode(this.mode)
                    QueueFormService.set_videos_path(this.videos_path)
                    QueueFormService.set_video_volume(parseInt(this.video_volume))
                    QueueFormService.set_images_path(this.images_path)
                    QueueFormService.set_queue_name_size(parseInt(this.name_size))
                    QueueFormService.set_queue_head_size(parseInt(this.head_size))
                    QueueFormService.set_queue_title_size(parseInt(this.title_size))
                  }
                };
              } else {
                $scope.queue_form_setting = {
                  images_path: QueueFormService.get_images_path(),
                  name_size: QueueFormService.get_queue_name_size(),
                  head_size: QueueFormService.get_queue_head_size(),
                  title_size: QueueFormService.get_queue_title_size(),
                  enable: QueueFormService.get_queue_form_enable(),
                  submit: function () {
                    if (QueueFormService.set_images_path(this.images_path)) {
                      QueueFormService.set_queue_name_size(parseInt(this.name_size))
                      QueueFormService.set_queue_head_size(parseInt(this.head_size))
                      QueueFormService.set_queue_title_size(parseInt(this.title_size))
                      // QueueFormService.set_queue_form_enable(this.enable)
                    } else {
                      $rootScope.alert("该文件路径不存在")
                    }
                  }
                };
              }

              for (var name in $scope.queue_form_setting) {
                var getter = $scope.queue_form_setting[name]
                if (getter instanceof Promise || (getter.then && getter.catch)) {
                  (function () {
                    var theName = name;
                    getter.then(function (value) {
                      $scope.$apply(function () {
                        $scope.queue_form_setting[theName] = value
                      })
                    });
                  })();
                }
              }

            })
            .catch(function (err) {
              console.error("invoke can_set_video error", err)
            })
        }

        // 快餐客显设置
        if (FastfoodFormService.has_object()) {
          $scope.fastfood_form_setting = {
            images_path: FastfoodFormService.get_images_path(),
            images_interval: FastfoodFormService.get_images_interval(),
            submit: function(){
              FastfoodFormService.set_images_path(this.images_path);
              FastfoodFormService.set_images_interval(this.images_interval);
            }
          }

          for (var name in $scope.fastfood_form_setting) {
            var getter = $scope.fastfood_form_setting[name]
            if (getter instanceof Promise || (getter.then && getter.catch)) {
              (function () {
                var theName = name;
                getter.then(function (value) {
                  $scope.$apply(function () {
                    $scope.fastfood_form_setting[theName] = value
                  })
                });
              })();
            }
          }
        }

        // 通用客显设置
        $scope.extended_form_setting = {
          //enable: ExtendedFormService.get_extended_form_enable(),
          change_enable: function(enable){
            this.enable = enable; this.submit();
          },
          submit: function(){
            ExtendedFormService.set_extended_form_enable(this.enable)
          }
        }

        ExtendedFormService.get_extended_form_enable().then(function(enable){
          $scope.extended_form_setting.enable = enable
        })

      }

      // 语音设置
      $scope.voice_setting = {
        vcn: TtsService.get_vcn(),
        spd: TtsService.get_spd(),
        vol: TtsService.get_vol(),
        vcns: TtsService.get_vcns(),
        spds: [1,2,3,4,5,6,7,8,9,10],
        vols: [1,2,3,4,5,6,7,8,9,10],
        change_vcn: function(vcn){
          this.vcn = vcn.value
          TtsService.set_vcn(this.vcn)
        },
        change_spd: function(spd){
          this.spd = spd
          TtsService.set_spd(this.spd)
        },
        change_vol: function(vol){
          this.vol = vol
          TtsService.set_vol(this.vcn)
        },
        test: function(){
          TtsService.play('您好，感谢您使用点 单 宝 收银系统！', 3);
        }
      }

      // 读卡器设置
      $scope.card_setting = {
        clear_card: function(){
          $rootScope.confirm("确定重置并清空卡片信息?", function(){
            CardReaderService.clear_card().then(function(resp){
              if (resp) {
                $rootScope.alert("重置并清空卡片信息成功!")
              }
            })
          })
        }
      }

      $scope.cash_box_setting = {
        auto_open_cash_box: CashBoxSettingService.getAutoOpen(),
        change_setting: function(option){
          if(this.auto_open_cash_box != option){
            this.auto_open_cash_box = option;
            CashBoxSettingService.setAutoOpen(option);
          }
        }
      }

      // 快捷键设置
      $scope.hotkey_setting = {
        hotkey: HotkeyService.get(),
        change_key: function(index, key){
          this.hotkey[index] = key;
          HotkeyService.set(index, key)
        }
      }

    }])
