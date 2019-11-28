(function () {
    return {
        config: {
            query: {
                code: 'db_Report_7_4',
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
                    width: 200
                }, 
                {
                    caption: 'у тому числі питання:',
                    columns: [
                        {
                            caption: 'комунального господарства',
                            alignment: 'center',
                            height: 150,
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevCommunal',
                                    alignment: 'center',
                                    
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curCommunal',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'житлової політики',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevResidential',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curResidential',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'екології та природних ресурсів',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevEcology',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curEcology',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'забезпечення дотримання законності та охорони правопорядку, запобігання дискримінації',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevLaw',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curLaw',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'сімейної та гендерної політики, захисту прав дітей',
                            alignment: 'center',
                            columns: [
                                {
                                    caption: 'previousYear',
                                    dataField: 'prevFamily',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }, {
                                    caption: 'currentYear',
                                    dataField: 'curFamily',
                                    alignment: 'center',
                                    customizeText: function(cellInfo) {
                                        let value = cellInfo.value === null ? ' - ' :  cellInfo.value ;
                                        return value;
                                    }
                                }
                            ]
                        }, {
                            caption: 'освіти, наукової, науково-технічної, інноваційної діяльності та інтелектуальної власності',
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
                                    dataField: 'curSince',
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
            const position = 2;
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
