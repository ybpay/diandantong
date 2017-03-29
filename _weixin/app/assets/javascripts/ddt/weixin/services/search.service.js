Ddt.factory('SearchService',
    ['DdtConst', 'BranchService',
        function (DdtConst, BranchService) {
            var search_words = JSON.parse($('meta[name="search_words_json"]').attr("content"));

            function getSearchWord(success) {
                success(search_words);
            }

            return {
                getSearchWord: getSearchWord,
                search: function(words, success){
                    return BranchService.query({
                        'query[name_cont]': words
                    }, success);
                }
            }
        }]);
