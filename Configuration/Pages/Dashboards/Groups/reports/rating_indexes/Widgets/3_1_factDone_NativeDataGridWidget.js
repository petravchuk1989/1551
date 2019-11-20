(function () {
    return {
        config: {
            query: {
                code: 'IndexOfFactToExecution',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [],
            summary: {
                totalItems: [],
            },
            scrolling: {
                mode: 'virtual'
            },
            filterRow: {
                visible: true,
                applyFilter: "auto"
            },
            showBorders: false,
            showColumnLines: false,
            showRowLines: true,
            remoteOperations: null,
            allowColumnReordering: null,
            rowAlternationEnabled: null,
            columnAutoWidth: null,
            hoverStateEnabled: true,
            columnWidth: null,
            wordWrapEnabled: true,
            allowColumnResizing: true,
            showFilterRow: true,
            showHeaderFilter: false,
            showColumnChooser: false,
            showColumnFixing: true,
            groupingAutoExpandAll: null,
        },
        init: function() {
            this.results = [];
            this.dataGridInstance.height = window.innerHeight - 200;
            this.active = false;
            document.getElementById('containerFactDone').style.display = 'none';
            this.sub = this.messageService.subscribe('showTable', this.showTable, this);
            this.sub1 = this.messageService.subscribe('FilterParameters', this.executeQuery, this);
            this.sub2 = this.messageService.subscribe( 'ApplyGlobalFilters', this.renderTable, this );
        },
        showTable: function(message){
            let tabName = message.tabName;
            if(tabName !== 'tabFactDone'){
                this.active = false;
                document.getElementById('containerFactDone').style.display = 'none';
            }else {
                this.active = true;
                document.getElementById('containerFactDone').style.display = 'block';
                this.renderTable();
            }
        },
        executeQuery: function (message) {
            this.period = message.period;
            this.rating = message.rating;
            this.executor = message.executor;
            this.parameters = message.parameters;
            this.districts = message.districts;
            let executeQuery = {
                queryCode: this.config.query.code,
                parameterValues: this.parameters,
                limit: -1
            };
            this.queryExecutor(executeQuery, this.setColumns, this);  
        },
        setColumns: function (data) {
            for (let i = 0; i < data.columns.length; i++) {
                
                const element = data.columns[i];
                if( element.code !== 'QuestionTypeId') {
                    let format = undefined;
                    const width = i === 1 ? 400 : 120;
                    const dataField = element.code;
                    const caption = this.setCaption(element.name);
                    const columnSliced =  element.name.slice(0, 7);
                    if(columnSliced === 'Percent') {
                        format = function (value) {
                            return value.toFixed(2);
                        }
                    }
                    const obj = { dataField, caption, width, format }
                    this.config.columns.push(obj);
                }
            }   
            this.config.keyExpr = data.columns[0].code;
            this.config.columns[0].fixed = true;
            let executeQuery = {
                queryCode: 'IndexOfFactToExecution_ResultPercent',
                parameterValues: this.parameters,
                limit: -1
            };
            this.queryExecutor(executeQuery, this.setColumnsSummary, this); 
        },
        setCaption: function (caption) {
            if(caption === 'QuestionTypeName') {
                return '';
            } else if(caption === 'EtalonDays') {
                return 'Середнє (еталон)';
            } else {
                const id = +caption.slice(-1);
                const index = this.districts.findIndex(el => el.id === id );
                return this.districts[index].name;
            }
            
        },
        setColumnsSummary: function (data) {

            for (let i = 0; i < data.columns.length; i++) {
                const element = data.columns[i];
                const dataField = "Place_" + element.code;
                const value = data.rows[0].values[i];
                const dataType = element.dataType;

                let objAvg = {
                    column: dataField,
                    summaryType: "avg",
                    customizeText: function(data) {
                        return data.value.toFixed(2);
                    },
                }
                let obj = {
                    column: dataField,
                    name: dataField,
                    summaryType: "custom"
                }
                this.results.push(value);
                this.config.summary.totalItems.push(objAvg);
                this.config.summary.totalItems.push(obj);
            }
            this.config.summary.calculateCustomSummary = this.calculateCustomSummary.bind(this);
            this.config.query.parameterValues = this.parameters;
            this.loadData(this.afterLoadDataHandler);        
        },
        calculateCustomSummary: function (options) {
            switch (options.name) {
                case 'Place_2000':
                    options.totalValue = this.results[0].toFixed(2);
                    break;
                case 'Place_2001':
                    options.totalValue = this.results[1].toFixed(2);
                    break;
                case 'Place_2002':
                    options.totalValue = this.results[2].toFixed(2);
                    break;
                case 'Place_2003':
                    options.totalValue = this.results[3].toFixed(2);
                    break;
                case 'Place_2004':
                    options.totalValue = this.results[4].toFixed(2);
                    break;
                case 'Place_2005':
                    options.totalValue = this.results[5].toFixed(2);
                    break;
                case 'Place_2006':
                    options.totalValue = this.results[6].toFixed(2);
                    break;
                case 'Place_2007':
                    options.totalValue = this.results[7].toFixed(2);
                    break;
                case 'Place_2008':
                    options.totalValue = this.results[8].toFixed(2);
                    break;
                case 'Place_2009':
                    options.totalValue = this.results[9].toFixed(2);
                    break;
                default:
                    break;
            }
        },        
        renderTable: function () {
            if (this.period) {
                if (this.active) {
                    let msg = {
                        name: "SetFilterPanelState",
                        package: {
                            value: false
                        }
                    };
                    this.messageService.publish(msg);
                    this.config.query.parameterValues = this.parameters;
                    this.loadData(this.afterLoadDataHandler);  
                }
            }
        },
        afterLoadDataHandler: function(data) {
            this.render();
        },
        destroy: function () {
            this.sub.unsubscribe();
            this.sub1.unsubscribe();
            this.sub2.unsubscribe();
        }
    };
  }());
  