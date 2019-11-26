(function () {
    return {
        config: {
            query: {
                code: 'db_ReestrRating1',
                parameterValues: [
                    {key: '@DateCalc' , value: 1 },
                    {key: '@RDAId', value: 0 },
                    {key: '@RatingId', value: 1 }

                ],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [
                {
                    dataField: 'RDAId',
                    caption: 'Назва установи',
                    fixed: true
                }, {
                    caption: 'Зареєстровано, В роботі, На доопрацюванні, На перевірці за попередній період',
                    alignItems: 'middle',
                    columns: [
                        {
                            dataField: 'PreviousPeriod_Total',
                            caption: 'Всього',
                        }, {
                            dataField: 'PreviousPeriod_Registered',
                            caption: 'Зареєстровано',
                        }, {
                            dataField: 'PreviousPeriod_InTheWorks',
                            caption: 'В роботі',
                        }, {
                            dataField: 'PreviousPeriod_InTest',
                            caption: 'На перевірці',
                        }, {
                            dataField: 'PreviousPeriod_ForRevision',
                            caption: 'На доопрацюванні',
                        }, {
                            dataField: 'PreviousPeriod_Closed',
                            caption: 'Закрито',
                        } 
                    ]
                }   
            ],
            columnChooser: {
                enabled: true
            },   
            showBorders: false,
            showColumnLines: true,
            showRowLines: true,
            remoteOperations: null,
            allowColumnReordering: null,
            rowAlternationEnabled: null,
            columnAutoWidth: true,
            hoverStateEnabled: true,
            columnWidth: null,
            wordWrapEnabled: true,
            allowColumnResizing: true,
            showFilterRow: true,
            showHeaderFilter: false,
            showColumnChooser: true,
            showColumnFixing: true,
            groupingAutoExpandAll: null,

        },
        init: function() {
            document.getElementById('infoContainer').style.display = 'none';
            this.sub = this.messageService.subscribe( 'FiltersParams', this.setFiltersParams, this );  
            this.sub1 = this.messageService.subscribe( 'showInfo', this.showInfo, this );  
        },
        showInfo: function (message) {
            document.getElementById('infoContainer').style.display = 'block';
        },
        setFiltersParams: function (message) {
            this.date = message.date;
            this.executor =   message.executor;
            this.rating =   message.rating;
            // this.config.query.parameterValues = [ 
            //     {key: '@DateCalc' , value: this.date },
            //     {key: '@RDAId', value: this.executor },  
            //     {key: '@RatingId', value: this.rating } 
            // ];
            this.loadData(this.afterLoadDataHandler);
        },
        afterLoadDataHandler: function(data) {
            this.render();
        },
    };
}());
