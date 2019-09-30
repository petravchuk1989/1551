(function () {
  return {
    config: {
        query: {
            code: '',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'EnterNumber',
                caption: 'Вхiдний номер УГЛ',
            },{
                dataField: 'RegistrationDate',
                caption: 'Дата реєстрації',
            },{
                dataField: 'Applicant',
                caption: 'Заявник',
            },{
                dataField: 'Address',
                caption: 'Адреса',
            },{
                dataField: 'Content',
                caption: 'Змiст',
            },{
                dataField: 'QuestionNumber',
                caption: 'Номер питання',
            }
        ],
        keyExpr: 'Id'
    },
    init: function() {
        this.sub = this.messageService.subscribe( 'GlobalFiltersChanged', this.getFiltersParams, this);
        this.sub1 = this.messageService.subscribe( 'ApplyGlobalFilters', this.applyChanges, this);
        this.sub2 = this.messageService.subscribe( 'showTable', this.showTable, this);
    },
    getFiltersParams: function(message){
        this.config.query.filterColumns = [];
        let period = message.package.value.values.find(f => f.name === 'period').value;
        let processed = message.package.value.values.find(f => f.name === 'processed').value;
        let users = message.package.value.values.find(f => f.name === 'users').value;

        if( period !== null ){
            if( period.dateFrom !== '' && period.dateTo !== ''){

                this.dateFrom =  period.dateFrom;
                this.dateTo = period.dateTo;
                this.users = extractOrgValues(users);
                this.processed = processed === null ? null : processed === '' ? null : processed.value;
                this.config.query.parameterValues = [ 
                    {key: '@dateFrom' , value: this.dateFrom },  
                    {key: '@dateTo', value: this.dateTo },  
                    {key: '@processed', value: this.processed } 
                ];
                if (this.users.length > 0) {
                    let filter = {
                        key: "users",
                        value: {
                            operation: 0,
                            not: false,
                            values: this.users
                        }
                    };
                    this.config.query.filterColumns.push(filter);
                }
                this.loadData(this.afterLoadDataHandler);
            }
        }

        function extractOrgValues(val) {
            if(val !== null){
                let valuesList = [];
                if (val.length > 0) {
                    for (let i = 0; i < val.length; i++) {
                        valuesList.push(val[i].value);
                    }
                }    
                return  valuesList.length > 0 ? valuesList : [];
            }else{
                return [];
            }
        }
    },
    applyChanges: function(message) {
        this.loadData(this.afterLoadDataHandler);
    },
    showTable: function(message) {
        this.loadData(this.afterLoadDataHandler);
    },
    afterLoadDataHandler: function(data) {
        this.render();
    },
    destroy: function (){
        this.sub.unsubscribe();
        this.sub1.unsubscribe();
        this.sub2.unsubscribe();
    }
};
}());
