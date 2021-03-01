(function() {
    return {
        chartConfig: {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Надійшло звернень з сайту з'
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
            colors: ['#15BDF4', '#2CD395', '#A0AFCF','#8F949A'],
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
                this.recalcData();
            }
        },
        init() {
            this.subscribers.push(this.messageService.subscribe('GlobalFilterChanged', this.executeSql, this));
            this.sendQuery = true;
            this.subscribers.push(this.messageService.subscribe('ApplyGlobalFilters', this.recalcData, this));
        },
        recalcData: function() {
            const msg = {
                name: 'SetFilterPanelState',
                package: {
                    value: false
                }
            };
            this.messageService.publish(msg);
            let executeQuery = {
                queryCode: 'SAFS_graph_Received',
                parameterValues: [
                    {key: '@date_from', value: this.toUTC(this.dateFrom)},
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
            let rows = params.rows
            let columns = params.columns;
            this.chartConfig.xAxis.categories = [];
            this.chartConfig.series = [];
            const dateIndex = columns.findIndex(c=>c.code === 'date');
            const valueIndex = columns.findIndex(c=>c.code === 'indicator_value');
            this.chartConfig.xAxis.categories = rows.map(row => this.changeDateTimeValues(row.values[dateIndex]));
            const data = rows.map(row => row.values[valueIndex]);
            const name = 'Кількість звернень';
            this.chartConfig.series.push({name,data})
            this.render();
        }
    };
}());
