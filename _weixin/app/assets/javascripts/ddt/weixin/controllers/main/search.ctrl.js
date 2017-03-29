"use strict"

Ddt.controller('searchController', [
    '$rootScope', '$scope', '$location', 'SearchService',
    function ($rootScope, $scope, $location, SearchService) {

        SearchService.getSearchWord(function (search_words) {
            $scope.search_word_groups = group_in(search_words, 3)
            console.log(search_words)
        });

        setTimeout(function () {
            $("input[type='text']:first-child").focus();
        });

        $scope.$watch('word', function(newVal, oldVal){
            SearchService.search($scope.word, function(data){
                $scope.branch_results = data;
            });
        });

        $scope.update = function(word){
            $scope.word = word;
        };

        $scope.is_recording = false;

        function onRecordEnd(res) {
            var localId = res.localId;
            wx.translateVoice({
                localId: localId, // 需要识别的音频的本地Id，由录音相关接口获得
                isShowProgressTips: 1, // 默认为1，显示进度提示
                success: function (res) {
                    $scope.$apply(function(){
                        if(res.translateResult) {
                            $scope.word = res.translateResult.replace("?", '').replace(".", '').replace("。", ''); // 语音识别的结果
                        }
                    });
                }
            });
        }

        $scope.startRecord = function() {
            $scope.is_recording = true;
            wx.startRecord({
                fail: function(){
                    alert('用户拒绝授权录音');
                }
            });
        }


        $scope.stopRecord = function() {
            $scope.is_recording = false;
            wx.stopRecord({
                success: onRecordEnd
            });
        }

        //强制将未结束的录音过程结束
        wx.stopRecord({
            success: function(){
                $scope.is_recording = false;
            }
        });

        wx.onVoiceRecordEnd({
            // 录音时间超过一分钟没有停止的时候会执行 complete 回调
            complete: onRecordEnd
        });


    }]);
