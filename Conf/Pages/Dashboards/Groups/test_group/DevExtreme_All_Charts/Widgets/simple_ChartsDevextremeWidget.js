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
                height: 300
            },
            series: {
                argumentField: "val",
                valueField: "Name",
                name: "My oranges",
                type: "bar",
                color: '#ffaa66'
            },
            export: {
                enabled: true
            },
            tooltip: {
                zIndex: 9999,
                enabled: true,
                location: "edge",
                customizeTooltip: function (arg) {
                    return {
                        text: "Open: $" + arg.argument + "<br/>" +
                                "Close: $" + arg.originalValue + "<br/>"
                    };
                }
            }
        },
        init: function() {
            this.loadData(this.afterLoadDataHandler);
        },
        afterLoadDataHandler: function(data) {
            this.render(data);
        }
    };
}());
