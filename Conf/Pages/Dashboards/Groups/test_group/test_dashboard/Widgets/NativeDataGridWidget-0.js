(function() {
    return {
        config: {
            query: {
                code: '',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [
                {
                    dataField: 'Column code',
                    caption: 'Caption'
                }
            ],
            keyExpr: 'Id'
        },
        init: function() {
            /* console.log('Data grid виджет работает'); */
        }
    };
}());
