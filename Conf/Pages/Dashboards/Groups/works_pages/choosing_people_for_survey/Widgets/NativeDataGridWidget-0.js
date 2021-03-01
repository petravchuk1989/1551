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
            this.loadData(this.afterLoadDataHandler);
        },
        afterLoadDataHandler: function() {
            this.render();
        }
    };
}());
