(function() {
    return {
        chartConfig: {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Повернуто заявникові'
            },
            subtitle: {
                text: ''
            },
            xAxis: {
            },
            yAxis: {
                title: {
                    text: ''
                }
            },
            colors: ['#c9e6e3', '#f9cdcc', '#f9f4b6','#8e83bd','#f6f3b6','#5fb3aa','#bbb9b6','#484846','#f6b1af','#fff78a'],
            tooltip: {
                headerFormat: '<span style="font-size:10px"></span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b>{point.y} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            plotOptions: {
                column: {
                    pointPadding: 0.2,
                    borderWidth: 0
                }
            },
            series: []
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
                queryCode: 'SAFS_graph_Returned',
                parameterValues: [{key: '@date_from', value: this.toUTC(this.dateFrom)},
                    {key: '@date_to', value: this.dateTo}
                ],
                limit: -1
            };
            this.queryExecutor(executeQuery, this.load, this);
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
        changeDateTimeValues: function(value) {
            let date = new Date(value);
            let dd = date.getDate().toString();
            let mm = (date.getMonth() + 1).toString();
            let yyyy = date.getFullYear().toString();
            dd = dd.length === 1 ? '0' + dd : dd;
            mm = mm.length === 1 ? '0' + mm : mm;
            return `${dd}.${mm}.${yyyy}`;
        },
        load: function(params) {
            this.chartConfig.series = [];
            let rows = params.rows;
            let columns = params.columns;
            const indicatorValueIndex = columns.findIndex(c=>c.code === 'indicator_value');
            const IsSendErrorIndex = columns.findIndex(c=>c.code === 'IsSendError_value');
            const dateIndex = columns.findIndex(c=>c.code === 'date');
            this.chartConfig.xAxis.categories = rows.map(row => this.changeDateTimeValues(row.values[dateIndex]));
            const indicatorValueName = 'Звернень з сайту'
            const data = rows.map(elem=>{
                let value = 0;
                value = elem.values[indicatorValueIndex]
                return value
            })
            this.chartConfig.series.push({name:indicatorValueName,data});
            const IsSendErrorName = 'Помилок при відправці хуків'
            const dataError = rows.map(elem=>{
                let value = 0;
                value = elem.values[IsSendErrorIndex]
                return value
            })
            this.chartConfig.series.push({name:IsSendErrorName,data:dataError});
            this.render()
        }
    };
}());
