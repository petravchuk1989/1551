(function () {
    return {

        config: {
            query: {
                code: 'db_Report_7_1',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [
                {
                caption: 'Кількість звернень',
                columns: [
                        {
                            caption: 'усіх',
                            alignment: 'center',
                            height: 100,
                            columns: [
                                {
                                    caption: '2018',
                                    dataField: 'qtyPrev',
                                    alignment: 'center',
                                }, {
                                    caption: '2019',
                                    dataField: 'qtyCurrent',
                                    alignment: 'center',
                                }
                            ]
                        }, {
                            caption: 'що надійшли поштою (п. 1.1)*',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: '2018',
                                    dataField: 'qtyMail_prev',
                                    alignment: 'center',
                                    
                                }, {
                                    caption: '2019',
                                    dataField: 'qtyMail_curr',
                                    alignment: 'center',
                                }
                            ]
                            
                        }, {
                            caption: 'на особистому прийомі (п. 1.2)*',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: '2018',
                                    dataField: 'qtyPersonal_prev',
                                    alignment: 'center',
                                    
                                }, {
                                    caption: '2019',
                                    dataField: 'qtyPersonal_curr',
                                    alignment: 'center',
                                }
                                
                            ]
                        },
                ]
                }, {
                    caption: 'Результати розгляду звернень:',
                    alignment: 'center',
                    columns: [
                        {
                            caption: 'вирішено позитивно (виконано) п. 9.1',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: '2018',
                                    dataField: 'qtyPos_prev',
                                    alignment: 'center',
                                }, {
                                    dataField: 'qtyPos_curr',
                                    alignment: 'center',
                                    caption: '2019',
                                }
                            ]
                        }, {
                            
                            caption: 'відмолено у задоволенні (не виконано) п. 9.2',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: '2018',
                                    dataField: 'qtyNeg_prev',
                                    alignment: 'center',
                                }, {
                                    dataField: 'qtyNeg_curr',
                                    alignment: 'center',
                                    caption: '2019',
                                }
                            ]
                        }, {
                            caption: 'дано роз’яснення п. 9.3',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: '2018',
                                    dataField: 'qtyExpl_prev',
                                    alignment: 'center',
                                }, {
                                    dataField: 'qtyExpl_curr',
                                    alignment: 'center',
                                    caption: '2019',
                                }
                            ]
                        }, {
                            caption: 'інше п. 9.4 - 9.6',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: '2018',
                                    dataField: 'qtyElse_prev',
                                    alignment: 'center',
                                }, {
                                    dataField: 'qtyElse_curr',
                                    alignment: 'center',
                                    caption: '2019',
                                }
                            ]
                        }
                    ]
                }
            ],
            keyExpr: 'qtyExpl_prev'
        },

        init: function() {
            this.sub =  this.messageService.subscribe( 'FiltersParams', this.setFilterParams, this );
            this.config.onContentReady = this.afterRenderTable.bind(this);
        },

        afterRenderTable: function() {
            this.messageService.publish({
                name: 'setYears',
                columns: this.config.columns
            });
        }, 

        setFilterParams: function (message) {
            this.config.query.parameterValues = [
                {key: '@dateFrom' , value:  message.dateFrom },  
                {key: '@dateTo', value: message.dateTo } 
            ];
            this.loadData(this.afterLoadDataHandler);
        }, 

        afterLoadDataHandler: function(data) {
            const name = 'setData';
            const columns = this.config.columns;
            const position = 0;
            this.messageService.publish( {name, data, columns, position} );
            this.render(this.afterRenderTable());
        },   
        afterRenderTable: function (params) {
            this.messageService.publish({ name: 'setStyles'});
        },
        destroy: function() {
            this.sub.unsubscribe();
        },
    };
}());
