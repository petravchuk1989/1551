(function() {
    return (function() {
        return {
            chartConfig: {
                chart: {
                    plotBackgroundColor: null,
                    plotBorderWidth: null,
                    plotShadow: false,
                    type: 'pie'
                },
                title: {
                    text: 'Кількість іногородніх заявників'
                },
                subtitle:{
                    text: ''
                },
                tooltip: {
                    pointFormat: '{series.name} <b>{point.percentage:.1f}%</b>'
                },
                yAxis: {
                    title: {
                        text: 'Кількість звернень'
                    }
                },
                colors: ['#c9e6e3', '#f9cdcc', '#f9f4b6','#8e83bd'],
                accessibility: {
                    point: {
                        valueSuffix: '%'
                    }
                },
                plotOptions: {
                    pie: {
                        allowPointSelect: true,
                        cursor: 'pointer',
                        dataLabels: {
                            enabled: false
                        },
                        showInLegend: true
                    }
                },
                series: [{
                    name: 'Brands',
                    colorByPoint: true,
                    data: [{
                        name: 'Chrome',
                        y: 61.41
                    }, {
                        name: 'Internet Explorer',
                        y: 11.84
                    }, {
                        name: 'Firefox',
                        y: 10.85
                    }, {
                        name: 'Edge',
                        y: 4.67
                    }, {
                        name: 'Safari',
                        y: 4.18
                    }, {
                        name: 'Other',
                        y: 7.05
                    }]
                }]
            },
            executeSql: function(message) {
                function checkDateFrom(val) {
                    return val ? val.dateFrom : null;
                }
                function checkDateTo(val) {
                    return val ? val.dateTo : null;
                }

                if (message.package.value.values.find(f => f.name === 'DateAndTime').value) {
                    this.dateFrom = checkDateFrom(message.package.value.values.find(f => f.name === 'DateAndTime').value);
                }
                if (message.package.value.values.find(f => f.name === 'DateAndTime').value) {
                    this.dateTo = checkDateTo(message.package.value.values.find(f => f.name === 'DateAndTime').value);
                }
                this.chartConfig.subtitle.text = `${this.changeDateTimeValues(this.dateFrom)} по ${this.changeDateTimeValues(this.dateTo)}`;
                if(this.sendQuery) {
                    this.sendQuery = false;
                    this.recalcData()
                }
            },
            init() {
                this.subscribers.push(this.messageService.subscribe('GlobalFilterChanged', this.executeSql, this));
                this.sendQuery = true;
                this.subscribers.push(this.messageService.subscribe('ApplyGlobalFilters', this.recalcData, this));
            },
            recalcData: function() {
                let executeQuery = {
                    queryCode: 'SAFS_CItySRows',
                    parameterValues: [{key: '@date_from', value: this.toUTC(this.dateFrom)},
                        {key: '@date_to', value: this.dateTo}
                    ],
                    limit: -1
                };
                this.queryExecutor(executeQuery, this.load, this);
            },
            changeDateTimeValues: function(value) {
                let date = new Date(value);
                let dd = date.getDate().toString();
                let mm = (date.getMonth() + 1).toString();
                let yyyy = date.getFullYear().toString();
                dd = dd.length === 1 ? '0' + dd : dd;
                mm = mm.length === 1 ? '0' + mm : mm;
                return `${dd}.${mm}.${yyyy}`;
            },
            toUTC(val) {
                let date = new Date(val);
                let year = date.getFullYear();
                let monthFrom = date.getMonth();
                let dayTo = date.getDate();
                let hh = date.getHours();
                let mm = date.getMinutes();
                let dateTo = new Date(year, monthFrom , dayTo, hh + 3, mm)
                return dateTo
            },
            load: function(data) {
                let rows = data.rows;
                let columns = data.columns;
                this.chartConfig.series[0].data = [];
                this.chartConfig.series[0].name = '';
                const inKyiv = columns.find(elem=>elem.code === 'in_Kyiv')
                const notInKyiv = columns.find(elem=>elem.code === 'in_not_Kyiv')
                const indexInKyiv = columns.indexOf(inKyiv)
                const indexNotInKyiv = columns.indexOf(notInKyiv)
                if(rows.length > 0) {
                    const inKyivObj = {
                        name: 'Кияни',
                        y: rows[0].values[indexInKyiv]
                    }
                    const notInKyivObj = {
                        name: 'Іногородні',
                        y: rows[0].values[indexNotInKyiv]
                    }
                    const newArr = [inKyivObj,notInKyivObj]
                    this.chartConfig.series[0].data = newArr;
                }
                this.render()
            }

        };
    }());
}());
