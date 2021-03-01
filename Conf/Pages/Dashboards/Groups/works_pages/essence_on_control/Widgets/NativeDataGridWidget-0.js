(function() {
    return {
        config: {
            query: {
                code: 'essence_table_SelectRows',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [
                {
                    dataField: 'RegistrationNumber',
                    caption: 'Номер'
                },
                {
                    dataField: 'RegistrationDate',
                    caption: 'Дата реєстрації',
                    dateType: 'datetime',
                    format: 'dd.MM.yyyy'
                },
                {
                    dataField: 'TypeName',
                    caption: 'Тип'
                },
                {
                    dataField: 'StateName',
                    caption: 'Стан'
                },
                {
                    dataField: 'OrganizationName',
                    caption: 'Виконавець'
                },
                {
                    dataField: 'ControlDate',
                    caption: 'Дата контролю',
                    dateType: 'datetime',
                    format: 'dd.MM.yyyy'
                },
                {
                    dataField: 'NotificationText',
                    caption: 'Остання нотифікація'
                },
                {
                    dataField: 'NotificationCreatedAt',
                    caption: 'Дата відправки',
                    dateType: 'datetime',
                    format: 'dd.MM.yyyy'
                }
            ],
            filterRow: {
                visible: true,
                applyFilter: 'auto'
            },
            pager: {
                showPageSizeSelector:  true,
                allowedPageSizes: [10, 15, 30],
                showInfo: true
            },
            paging: {
                pageSize: 10
            },
            scrolling: {
                mode: 'standart',
                rowRenderingMode: null,
                columnRenderingMode: null,
                showScrollbar: null
            },
            searchPanel: {
                visible: false,
                highlightCaseSensitive: true
            },
            selection: {
                mode: 'multiple'
            },
            sorting: {
                mode: 'multiple'
            },
            export: {
                fileName: 'Сутності на контролі'
            },
            keyExpr: 'Id',
            focusedRowEnabled: true,
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
            groupingAutoExpandAll: null
        },
        init: function() {
            this.subscribers.push(this.messageService.subscribe('SetButtonData', this.getData, this));
            this.config.onToolbarPreparing = this.createTableButton.bind(this);
            const self = this;
            this.dataGridInstance.onCellClick.subscribe(e => {
                e.event.stopImmediatePropagation();
                let val = null
                if(self.buttonData === 'question') {
                    val = 'Questions'
                } else if(self.buttonData === 'assignment') {
                    val = 'Assignments'
                } else if(self.buttonData === 'event') {
                    val = 'Events'
                }
                if(e.column) {
                    if(e.column.dataField === 'RegistrationNumber' && e.row !== undefined) {
                        window.open(location.origin + localStorage.getItem('VirtualPath') +
                         `/sections/${val}/edit/` + e.row.data.ReferenceId, '_blank');
                    }
                }
            });
        },
        createTableButton(e) {
            let toolbarItems = e.toolbarOptions.items;
            toolbarItems.push({
                widget: 'dxButton',
                location: 'after',
                options: {
                    icon: 'exportxlsx',
                    type: 'default',
                    text: 'Excel',
                    onClick: function() {
                        this.dataGridInstance.instance.exportToExcel();
                    }.bind(this)
                }
            });
            toolbarItems.push({
                widget: 'dxButton',
                options: {
                    icon: 'check',
                    type: 'default',
                    text: 'Зняти з контролю',
                    onClick: function(e) {
                        e.event.stopImmediatePropagation();
                        this.findAllSelectRowsToArrived();
                    }.bind(this)
                },
                location: 'after'
            });
        },
        findAllSelectRowsToArrived() {
            let rows = this.dataGridInstance.selectedRowKeys;
            const rowsValues = rows.map(elem=>{
                const obj = {Id: elem}
                return obj
            })
            const jsonRows = JSON.stringify(rowsValues)
            const getButtonsValues = {
                queryCode: 'essence_table_DeleteRows',
                limit: -1,
                parameterValues: [
                    {key: '@Group', value: this.buttonData},
                    {key: '@JSON', value: jsonRows}
                ]
            };
            this.queryExecutor(getButtonsValues,this.getNewTable,this);
        },
        getNewTable() {
            this.updateButtonsValues()
            this.loadData(this.afterLoadDataHandler)
        },
        getData(data) {
            this.buttonData = data.package.value
            this.config.query.parameterValues = [{key: '@Group', value: data.package.value}, {key: '@UserId', value: '1'}]
            this.loadData(this.afterLoadDataHandler)
        },
        updateButtonsValues() {
            let msg = {
                name: 'UpdateButtonValues',
                package: {
                    value: true
                }
            };
            this.messageService.publish(msg);
        },
        afterLoadDataHandler: function() {
            this.render();
        }
    };
}());
