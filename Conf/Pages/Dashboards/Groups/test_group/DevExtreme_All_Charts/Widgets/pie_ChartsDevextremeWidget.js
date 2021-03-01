(function () {
    return {
        config: {
            query: {
                code: 'DevExtreme_DataGrid_RowChart_SelectRows',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            size: {
                width: 500
            },
            palette: "bright",
            series: [
                {
                    argumentField: "Name",
                    valueField: "2010",
                    label: {
                        visible: true,
                        connector: {
                            visible: true,
                            width: 1
                        }
                    }
                }
            ],
            title: "Area of Countries",
            "export": {
                enabled: true
            },
            id: 'myPie'
        },
        init: function() {
            this.loadData(this.afterLoadDataHandler);
        },  
        afterLoadDataHandler: function() {
            this.render();
        }
    };
}());
