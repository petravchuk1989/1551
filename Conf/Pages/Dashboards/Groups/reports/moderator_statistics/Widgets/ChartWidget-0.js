(function() {
    return {
        chartConfig: {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Реєстрація з'
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
            if (message.package.value.values.find(f => f.name === 'period').value) {
                this.dateFrom = checkDateFrom(message.package.value.values.find(f => f.name === 'period').value);
            }
            if (message.package.value.values.find(f => f.name === 'period').value) {
                this.dateTo = checkDateTo(message.package.value.values.find(f => f.name === 'period').value);
            }
            if (message.package.value.values.find(f => f.name === 'operator').value) {
                this.operator = (message.package.value.values.find(f => f.name === 'operator').value);
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
            if(this.operator) {
                this.operator = this.operator.map(elem=>elem.value).join(',');
            }
            let executeQuery = {
                queryCode: 'db_ModStat_registration_graph1',
                parameterValues: [
                    {key: '@date_from', value: this.toUTC(this.dateFrom)},
                    {key: '@date_to', value: this.toUTC(this.dateTo)},
                    { key: '@user_Ids', value: this.toUTC(this.operator) }
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
            const userNameIndex = columns.findIndex(c=>c.code === 'leg_name');
            const userNameArr = rows.map(e=>e.values[userNameIndex]);
            const sortedUsers = [...new Set(userNameArr)];
            const filtered = columns.filter(c=>c.code !== 'leg_name' && c.code !== 'Id')
            const dateIndex = filtered.map(elem=>elem.code)
            this.chartConfig.xAxis.categories = dateIndex.map(row => (row))
            sortedUsers.forEach(name=>{
                const filteredData = rows.filter(elem=>elem.values.includes(name))
                const mapedData = filteredData.map(elem=>elem.values)
                const data = mapedData[0].slice(2)
                this.chartConfig.series.push({name,data});
            })
            this.render()
        }
    };
}());
