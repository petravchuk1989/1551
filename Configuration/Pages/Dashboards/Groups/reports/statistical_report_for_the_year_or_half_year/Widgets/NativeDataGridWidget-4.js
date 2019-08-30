(function () {
  return {
    config: {
        query: {
            code: 'db_Report_7_5',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'source',
                caption: ' ',
                width: 200,
                
            }, 
            {
                caption: 'у тому числі питання:',
                columns: [
                    {
                        caption: 'діяльність об’єднань громадян, релігії та міжконфесійних відносин',
                        alignment: 'center',
                        height: 150,
                        columns: [
                            {
                                caption: 'previoustYear',
                                dataField: 'prevReligy',
                                alignment: 'center',
                                
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }, {
                                caption: 'currentYear',
                                dataField: 'curReligy',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }
                        ]
                    }, {
                        caption: 'діяльність центральних органів виконавчої влади',
                        alignment: 'center',
                        columns: [
                            {
                                caption: 'previoustYear',
                                dataField: 'prevCentralExecutePower',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }, {
                                caption: 'currentYear',
                                dataField: 'curCentralExecutePower',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }
                        ]
                    }, {
                        caption: 'діяльність місцевих органів виконавчої влади',
                        alignment: 'center',
                        columns: [
                            {
                                caption: 'previoustYear',
                                dataField: 'prevLocalExecutePower',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }, {
                                caption: 'currentYear',
                                dataField: 'curLocalExecutePower',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }
                        ]
                    }, {
                        caption: 'діяльність органів місцевого самоврядування',
                        alignment: 'center',
                        columns: [
                            {
                                caption: 'previoustYear',
                                dataField: 'prevLocalMunicipalitet',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }, {
                                caption: 'currentYear',
                                dataField: 'curLocalMunicipalitet',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }
                        ]
                    }, {
                        caption: 'державного будівництва, адміністративно-територіального устрою',
                        alignment: 'center',
                        columns: [
                            {
                                caption: 'previoustYear',
                                dataField: 'prevStateConstruction',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }, {
                                caption: 'currentYear',
                                dataField: 'curStateConstruction',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }
                        ]
                    }, {
                        caption: 'інші',
                        alignment: 'center',
                        columns: [
                            {
                                caption: 'previoustYear',
                                dataField: 'prevOther',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }, {
                                caption: 'currentYear',
                                dataField: 'curOther',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }
                        ]
                    }, {
                        caption: 'Штатна чисельність роботи підрозділу зі зверненнями громадян',
                        alignment: 'center',
                        columns: [
                            {
                                caption: 'previoustYear',
                                dataField: 'prevEmployees',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }, {
                                caption: 'currentYear',
                                dataField: 'curEmployees',
                                alignment: 'center',
                                customizeText: function(cellInfo) {
                                    let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                    return value;
                                }
                            }
                        ]
                    }
                ]
            }, 
            
        ],
        keyExpr: 'source'
    },
    init: function() {
		let date = new Date();
        let yyyy = date.getFullYear();
	    this.currentYear = yyyy
        this.previoustYear = yyyy - 1;

        this.sub =  this.messageService.subscribe( 'GlobalFilterChanged', this.getFilterParams, this );
        this.config.onContentReady = this.afterRenderTable.bind(this);
        this.dataGridInstance.onContentReady = this.onContentReady(); 
    },   
    getFilterParams: function(message){
        let period = message.package.value.values.find(f => f.name === 'period').value;
        
	    if( period !== null ){
    		if( period.dateFrom !== '' && period.dateTo !== ''){
                this.dateFrom =  period.dateFrom;
                this.dateTo = period.dateTo;
                
        	    this.previoustYear = this.changeDateTimeValues(this.dateFrom);
        	    this.currentYear = this.changeDateTimeValues(this.dateTo);
        	    
        	    if( this.previoustYear === this.currentYear){
        	        
        	        this.previoustYear -= 1;
                    this.config.query.parameterValues = [ 
                        {key: '@dateFrom' , value: this.dateFrom },  
                        {key: '@dateTo', value: this.dateTo },  
                    
                    ];
                    this.loadData(this.afterLoadDataHandler);
        	    }else{
        	       // alert('оберIть правильну дату');
        	    }
	        }
	    }
    },
	afterRenderTable: function(){
	    
		let tds = document.querySelectorAll('td');
		tdsArr = Array.from(tds);
		tdsArr.forEach( el => {
		   el.style.whiteSpace = "pre-wrap";
		});
		
        let noWrapTdCollection = document.querySelectorAll('.dx-datagrid-text-content');
        let noWrapTdArr = Array.from(noWrapTdCollection);
        noWrapTdArr.forEach( td => {
            td.style.whiteSpace = "pre-wrap";
            td.parentElement.style.verticalAlign = "middle";
        });	
	},
	onContentReady: function(){
	   this.config.columns[1].columns.forEach( el => {
			el.columns[0].caption = this.previoustYear;
			el.columns[1].caption = this.currentYear;
		}); 
	},
	changeDateTimeValues: function(value){
        let date = new Date(value);
        let yyyy = date.getFullYear();
        return yyyy;
    },    
    afterLoadDataHandler: function(data) {
        this.render(this.onContentReady());
    },
    destroy: function(){
        this.sub.unsubscribe();
    },    
};
}());
