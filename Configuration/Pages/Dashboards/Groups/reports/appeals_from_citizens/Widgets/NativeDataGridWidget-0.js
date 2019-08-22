(function () {
  return {
    config: {
        query: {
            code: 'db_Report_1',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'Operator',
                caption: 'ПІП користувача',
            }, {
                dataField: 'AppealCount',
                caption: 'Звернень',
                alignment: 'center'
            }, {
                dataField: 'QuestionCount',
                caption: 'Питань',
                alignment: 'center'
            }, {
                dataField: 'DoneAssignments',
                caption: 'Виконано',
                alignment: 'center'
            }, {
                dataField: 'reWorkAssignments',
                caption: 'На доопрацювання',
                alignment: 'center'
            }, {
                dataField: 'notAnswerAssignments',
                caption: 'Недозвон',
                alignment: 'center'
            },
        ],
        summary: {
                totalItems: [{
                    column: "AppealCount",
                    summaryType: "sum",
                    customizeText: function(data) {
                    return "Сума: " + data.value;
                }
                }, {
                    column: "QuestionCount",
                    summaryType: "sum",
                    customizeText: function(data) {
                    return "Сума: " + data.value;
                }
                }, {
                    column: "DoneAssignments",
                    summaryType: "sum",
                    customizeText: function(data) {
                    return "Сума: " + data.value;
                }
                }, {
                    column: "reWorkAssignments",
                    summaryType: "sum",
                    customizeText: function(data) {
                    return "Сума: " + data.value;
                }
                }, {
                    column: "notAnswerAssignments",
                    summaryType: "sum",
                    customizeText: function(data) {
                    return "Сума: " + data.value;
                }
                }]
        },
        keyExpr: 'Id',
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
        this.dataGridInstance.height = window.innerHeight - 200;   
        this.guids = [];
        this.sub = this.messageService.subscribe('GlobalFilterChanged', this.getFiltersParams, this);
    },
    getFiltersParams: function(message){
        
        let period = message.package.value.values.find(f => f.name === 'period').value;
        let citizenName = message.package.value.values.find(f => f.name === 'citizen_name').value;
        
        if( period !== null ){
            if( period.dateFrom !== '' && period.dateTo !== ''){
                
                this.dateFrom = period.dateFrom;
                this.dateTo = period.dateTo;
                this.citizenName = extractOrgValues(citizenName);
        
                this.config.query.parameterValues = [ 
                    {key: '@dateFrom' , value: this.dateFrom },  
                    {key: '@dateTo', value: this.dateTo }  
                ];
                this.config.query.filterColumns = [];
                if (this.citizenName.length > 0) {
                    const filter = {
                        key: "Operator",
                        value: {
                                    operation: 0,
                                    not: false,
                                    values: this.citizenName
                                }
                    };
                        
                    this.config.query.filterColumns.push(filter);
                };
                this.loadData(this.afterLoadDataHandler);
                
                function extractOrgValues(val) {
                    if(val != null){
            	        var valuesList = [];
                	    if (val.length > 0) {
                	        for (var i = 0; i < val.length; i++) {
                	            valuesList.push(val[i].value);
                	        }
                	    }    
                	        return  valuesList.length > 0 ? valuesList : [];
                    } else {
                        return [];
                    };
            	}
        
            }    
        }
    },
    afterLoadDataHandler: function(data) {
        this.render();
    },
    destroy: function(){
        this.sub.unsubscribe();
    },
};
}());
