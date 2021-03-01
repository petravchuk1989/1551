(function () {
    return {
        config: {
            query: {
                code: 'ys_sankeyChartDevExtreme',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            sourceField: "source",
            targetField: "target",
            weightField: "weight",
            title: "Commodity Turnover in 2017",
            node: {
                width: 8,
                padding: 30
            },
            link: {
                colorMode: "gradient"
            },
            tooltip: {
                zIndex: 99999999999,
                enabled: true,
                customizeLinkTooltip: function(info) {
                    return {
                        html:
                            "<b>From:</b> " +
                            info.source +
                            "<br/><b>To:</b> " +
                            info.target +
                            "<br/>" +
                            "<b>Weight:</b> " +
                            info.weight
                    };
                }
            },
            id: 'mySankey'
        },
        init: function() {
            this.loadData(this.afterLoadDataHandler);
        },  
        afterLoadDataHandler: function() {
            this.render();
        }
    };
}());
