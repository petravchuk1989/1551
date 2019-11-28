(function () {
    return {
        config: {
            query: {
                code: 'db_Report_7_3',
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
                    wordWrapEnabled: true,
                    height: 150
                }, 
                {
                    caption: 'у тому числі питання:',
                    columns: [
                        {
                            caption: 'Кількість питань,порушених у зверненнях громадян',
                            alignment: 'center',
                            height: 150,
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevAll',
                                    alignment: 'center',
                                    
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curAll',
                                    alignment: 'center',
                                    wordWrapEnabled: true,
                                    height: 150,                                
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'аграрної політики і земельних відносин',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevAgr',
                                    alignment: 'center',
                                    wordWrapEnabled: true,
                                    height: 150,
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curAgr',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'транспорту і зв’язку',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevTrans',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curTrans',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'фінансової, податкової,митної політики',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevFinance',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curFinance',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'соціального захисту',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevSocial',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curSocial',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'праціі заробітної плати, охорони праці, промислової безпеки',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevWork',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curWork',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'охорони здоров’я',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevHealth',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curHealth',
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
            this.sub =  this.messageService.subscribe( 'FiltersParams', this.setFilterParams, this );
            this.config.onContentReady = this.afterRenderTable.bind(this);
        },

        afterRenderTable: function() {
            this.messageService.publish({
                name: 'setYears',
                columns: this.config.columns[1].columns
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
            const position = 3;
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
