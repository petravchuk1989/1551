(function () {
  return {
    config: {
        query: {
            code: 'db_ReestrRating1',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'Column code',
                caption: 'tableSpeedExplained',
            }
        ],
        keyExpr: 'Id'
    },
    init: function() {
        document.getElementById('tableSpeedExplained').style.display = 'none';
        this.sub = this.messageService.subscribe('showTable', this.showTable, this);
        this.sub1 = this.messageService.subscribe('GlobalFilterChanged', this.getFiltersParams, this);
        this.sub1 = this.messageService.subscribe( 'ApplyGlobalFilters', this.renderTable, this );
    },
    showTable: function(message){
        let tabName = message.tabName;
        if(tabName !== 'tabSpeedExplained'){
            document.getElementById('tableSpeedExplained').style.display = 'none';
        }else {
            document.getElementById('tableSpeedExplained').style.display = 'block';
            this.renderTable();
        }
    },
    getFiltersParams: function(message){
        let period = message.package.value.values.find(f => f.name === 'period').value;
        let executor = message.package.value.values.find(f => f.name === 'executor').value;
        let rating = message.package.value.values.find(f => f.name === 'rating').value;
        
        if( period !== '' ){
            this.period = period;
            this.executor = executor === null ? 0 :  executor === '' ? 0 : executor.value;
            this.rating = rating === null ? 0 :  rating === '' ? 0 : rating.value;
        }
    }, 
    renderTable: function () {
        if(this.period) {

            let msg = {
                name: "SetFilterPanelState",
                package: {
                    value: false
                }
            };
            this.messageService.publish(msg);
            this.config.query.parameterValues = [ 
                {key: '@DateCalc' , value: this.period },
                {key: '@RDAId', value: this.executor },  
                {key: '@RatingId', value: this.rating } 
            ];
            this.loadData(this.afterLoadDataHandler);  
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
