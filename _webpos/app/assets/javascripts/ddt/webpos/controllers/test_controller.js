;WebposModules.add_controller('test')
angular.module('webpos.controllers.test', []).
  controller('testController', ['$rootScope', '$scope', 'CardReaderService','CustomerDisplayService',
  'TtsService','FlashPlayerService','QueueFormService','WirePrinterService','ExtendedFormService',
    function($rootScope, $scope, CardReaderService, CustomerDisplayService,
             TtsService,FlashPlayerService, QueueFormService,WirePrinterService, ExtendedFormService){

      $rootScope.branch = null
      $scope.test = "test"
      $scope.sex_collection = [{ value: 'man', label: '先生'}, { value: 'female', label: '女士'}]

      var key = $rootScope.shop.card_key

      $scope.find_card = function(){
        CardReaderService.find_card().then(function(card_num){
          alert("寻卡: " + card_num)
        })
      }

      $scope.init_card = function(){
        CardReaderService.init_card(key).then(function(resp){
          alert("初始化: " + resp)
        })
      }

      $scope.init_card_other = function(){
        CardReaderService.init_card("111111111111").then(function(resp){
          alert("初始化其他: " + resp)
        });
      }

      $scope.clear_card = function(){
        CardReaderService.clear_card().then(function(resp){
          alert("逆初始化: " + resp)
        });
      }

      $scope.read = function(){
        CardReaderService.read(key).then(function(resp){
          alert("读数据:" + resp)
        })
      }

      $scope.write = function(){
        var str = "" + Math.floor(Math.random() * 10000)
        CardReaderService.write(key, str).then(function(resp){
          alert("写数据: " + resp)
        })
      }

      $scope.verify_vip = function(){
        $rootScope.vip_scan_verify("会员扫码识别", "客户扫码", function(vipinfo){
          // console.log(vipinfo)
        }, true, true)
      }

      $scope.display_data = function(display_type, data){
        CustomerDisplayService.display_data(display_type, data)
      }


      $scope.play = TtsService.play

      $scope.vcns = TtsService.get_vcns()
      $scope.vcn = TtsService.get_vcn()
      $scope.spds = [0,1,2,3,4,5,6,7,8,9,10]
      $scope.spd = TtsService.get_spd()
      $scope.vols = [0,1,2,3,4,5,6,7,8,9,10]
      $scope.vol = TtsService.get_vol()

      $scope.$watch("vcn", function(new_vcn){ TtsService.set_vcn(new_vcn)})
      $scope.$watch("spd", function(new_spd){ TtsService.set_spd(new_spd)})
      $scope.$watch("vol", function(new_vol){ TtsService.set_vol(new_vol)})

      $scope.sound_play = function(){ soundPlay() }

      $scope.check_flash = function(){
        var playerVersion = swfobject.getFlashPlayerVersion();
        var output = "You have Flash player " +
        playerVersion.major + "." + playerVersion.minor + "." +
        playerVersion.release + " installed";
        alert(output);
      }

      $scope.play_flash = function(){
        FlashPlayerService.play("/audios/order_placed.mp3", 2)
      }

      // queue_form
      $scope.qf = QueueFormService;
      $scope.ef = ExtendedFormService;

      $scope.show_qrcode = function(){
        ExtendedFormService.show_qrcode("微信扫码支付", "http://www.diandantong.com/assets/qrcode.jpg")
      }

      //wire printer
      $scope.print = function(){
        WirePrinterService.print("<CM>测试打印</CM>\n<CB>测试打印</CB>", 2)
      }
    }])
