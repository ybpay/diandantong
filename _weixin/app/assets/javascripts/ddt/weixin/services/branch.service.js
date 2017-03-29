Ddt.factory('BranchService', [
    'DdtConst', '$resource',
    function (DdtConst, $resource) {
        var baseUrl = DdtConst.baseUrl + '/branches';

        function buildResourceFilter(url, filterQuery) {
            return url + '?' + $.map(filterQuery, function (filter_args, filter_class) {
                return 'filters[' + filter_class + ']=' + filter_args
            }).join('&')
        }

        var res = $resource(
                baseUrl + '/:id.json',
            {},
            {
                filters: {method: 'get', isArray: true, cache: true, url: buildResourceFilter(baseUrl + '/filters.json', {
                    'tag_filter': '',
                    'zone_filter': '',
                    'branch_sort_filter': ''
                })},
                query: {method: 'GET', isArray: true, cache: true},
                queryNews: {method: 'GET', isArray: true, cache: false},
                get: {method: 'GET', cache: true}
            }
        );

        return {
            query: res.query,
            queryNews: res.queryNews,
            filters: res.filters,
            delivery_filters: res.delivery_filters,
            get: res.get
        };

    }
]);
