(function () {
  return {
        config: {
            query: {
                code: 'ys_testPolarChartDevExtreme',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            series: [
                {
                    valueField: "day",
                    name: "День",
                    color: "#ba4d51"
                },
                {
                    valueField: "night",
                    name: "Ночь",
                    color: "#5f8b95"
                }
            ],
            legend: {
                visible: false
            },
            argumentAxis: {
                inverted: true,
                startAngle: 90,
                tickInterval: 30
            },
            "export": {
                enabled: true
            },
            title: "Rose in Polar Coordinates",
            id: 'myCurrentRadar'
        },
        init: function() {
            this.loadData(this.afterLoadDataHandler);
        },
        afterLoadDataHandler: function() {
            this.render();
        }
    };
}());
