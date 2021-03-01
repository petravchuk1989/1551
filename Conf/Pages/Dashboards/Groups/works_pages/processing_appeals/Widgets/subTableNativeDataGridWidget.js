(function() {
    return {
        config: {
            query: {
                code: 'h_DB_ProApp_SubTable',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [
                {
                    dataField: 'registration_number',
                    caption: 'Номер питання',
                    width: 100
                }, {
                    dataField: 'registration_date',
                    caption: 'Дата реєстрації',
                    sortOrder: 'asc',
                    width: 120
                }, {
                    dataField: 'QuestionType',
                    caption: 'Тип питання'
                }, {
                    dataField: 'place_problem',
                    caption: 'Місце проблеми'
                }, {
                    dataField: 'control_date',
                    caption: 'Дата контролю',
                    width: 120
                }, {
                    dataField: 'vykonavets',
                    caption: 'Виконавець'
                }, {
                    dataField: 'lookup',
                    caption: 'Батьківська організація',
                    width: 300,
                    lookup: {
                        dataSource: undefined,
                        valueExpr: 'ID',
                        displayExpr: 'Name'
                    }
                }, {
                    caption: '',
                    dataField: 'phoneNumber',
                    alignment: 'center',
                    width: 40
                }, {
                    dataField: 'comment',
                    caption: 'Коментар'
                }
            ],
            masterDetail: {
                enabled: true
            },
            filterRow: {
                visible: true,
                applyFilter: 'auto'
            },
            pager: {
                showPageSizeSelector:  true,
                allowedPageSizes: [10, 50, 100, 500],
                showInfo: true
            },
            paging: {
                pageSize: 500
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
            sorting: {
                mode: 'multiple'
            },
            editing: {
                mode: 'cell',
                allowUpdating: true,
                useIcons: false
            },
            selection: {},
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
        arrivedColumn: 'arrived',
        isEvent: false,
        event: 'Заходи',
        lookupData: [],
        organizations: [],
        phoneNumberIndex: 4,
        init: function() {
            this.dataGridInstance.height = window.innerHeight - 405;
            this.executeQueryLookup();
            this.tableContainer = document.getElementById('subTable');
            this.setVisibilityTableContainer('none');
            this.subscribers.push(this.messageService.subscribe('clickOnHeaderTable', this.changeOnTable, this));
            this.subscribers.push(this.messageService.subscribe('hideSubTable', this.hideTable, this));
            this.config.masterDetail.template = this.createMasterDetail.bind(this);
            this.config.onCellPrepared = this.onCellPrepared.bind(this);
            this.config.onContentReady = this.afterRenderTable.bind(this);
            this.config.onCellPrepared = this.onCellPrepared.bind(this);
            this.dataGridInstance.onCellClick.subscribe(e => {
                if(e.column) {
                    if(e.column.dataField === 'registration_number' && e.row !== undefined) {
                        const id = this.isEvent ? e.data.registration_number : e.data.Id;
                        const form = this.isEvent ? 'Events' : 'Assignments';
                        window.open(`${location.origin}${localStorage.getItem('VirtualPath')}/sections/${form}/edit/${id}`);
                    }
                    if(e.column.dataField === 'phoneNumber' && e.row !== undefined) {
                        if(e.data.lookup) {
                            const index = this.organizations.rows.findIndex(o => o.values[0] === e.data.lookup);
                            if(index !== -1) {
                                const phone = this.organizations.rows[index].values[this.phoneNumberIndex];
                                if(phone) {
                                    this.callTo(phone);
                                }
                            }
                        } else {
                            this.callTo(e.data.phone_number);
                        }
                    }
                }
            });
        },
        callTo: function() {
            /*
                ЗДЕСЬ ДОЛЖНА БЫТЬ ОПИСАНА ЛОГИКА

                ВОЗМОЖНО ТАКАЯ:
                let CurrentUserPhone = e.row.data.phone_number;
                let PhoneForCall = this.userPhoneNumber;
                let xhr = new XMLHttpRequest();
                xhr.open('GET', 'https://cc.1551.gov.ua:5566/CallService/Call/number=' +
                CurrentUserPhone + '&operator=' + PhoneForCall);
                xhr.send();

                Взято  с ДБ "prozvon"
            */
        },
        onCellPrepared: function(options) {
            if(options.rowType === 'data') {
                if(options.column.dataField === 'phoneNumber') {
                    options.cellElement.innerText = '';
                    const phoneIcon = this.createElement('span', {className: 'material-icons', innerText: 'phone'});
                    options.cellElement.appendChild(phoneIcon);
                }
            }
        },
        executeQueryLookup: function() {
            let executeQueryStatuses = {
                queryCode: 'h_ParentPositions_SelectRows',
                limit: -1,
                parameterValues: []
            };
            this.queryExecutor(executeQueryStatuses, this.setLookupData, this);
        },
        setLookupData: function(data) {
            this.organizations = data;
            data.rows.forEach(row => {
                let organization = {
                    'ID': row.values[0],
                    'Name':  row.values[3],
                    'vykonavets_Id': row.values[1]
                }
                this.lookupData.push(organization);
            });
            const index = this.config.columns.findIndex(c => c.dataField === 'lookup');
            this.config.columns[index].lookup.dataSource = this.setLookupDataSource.bind(this);
        },
        setLookupDataSource: function(options) {
            const obj = {
                store: this.lookupData,
                filter: options.data ? ['vykonavets_Id', '=', options.data.vykonavets_Id] : null
            };
            return obj
        },
        createMasterDetail: function(container, options) {
            const currentEmployeeData = options.data;
            const name = 'createMasterDetail';
            const fields = {
                zayavnyk: 'Заявник',
                ZayavnykAdress: 'Адреса заявника',
                content: 'Зміст'
            };
            this.messageService.publish({
                name, currentEmployeeData, fields, container
            });
        },
        setVisibilityTableContainer: function(status) {
            this.tableContainer.style.display = status;
        },
        changeOnTable: function(message) {
            if (message.code && message.navigator) {
                this.isEvent = message.navigator === this.event ? true : false;
                this.config.selection.mode = 'single';
                if (message.code === this.arrivedColumn) {
                    this.config.selection.mode = 'multiple';
                }
                this.config.onToolbarPreparing = this.createTableButton.bind(this, message.code);
                this.setVisibilityTableContainer('block');
                this.config.query.parameterValues = [
                    { key: '@navigator', value: message.navigator},
                    { key: '@column', value: message.code}
                ];
                this.loadData(this.afterLoadDataHandler);
            } else {
                this.hideTable();
            }
        },
        createTableButton: function(code, e) {
            let toolbarItems = e.toolbarOptions.items;
            toolbarItems.push({
                widget: 'dxButton',
                location: 'after',
                options: {
                    icon: 'exportxlsx',
                    type: 'default',
                    text: 'Excel',
                    onClick: function() {
                        this.executeExportExcelQuery();
                    }.bind(this)
                }
            });
            if (code === this.arrivedColumn) {
                toolbarItems.push({
                    widget: 'dxButton',
                    name: 'transfer',
                    options: {
                        icon: 'upload',
                        type: 'default',
                        text: 'Передано',
                        onClick: function() {
                            this.findAllSelectedRows();
                        }.bind(this)
                    },
                    location: 'after'
                });
            }
        },
        executeExportExcelQuery: function() {
            this.showPagePreloader('Зачекайте, формується документ');
            let exportQuery = {
                queryCode: this.config.query.code,
                limit: -1,
                parameterValues: this.config.query.parameterValues
            }
            this.queryExecutor(exportQuery, this.createExcelWorkbook, this);
            this.showPreloader = false;
        },
        createExcelWorkbook: function(data) {
            const context = this;
            const name = 'exportExcel';
            const columns = [];
            this.config.columns.forEach(column => {
                if (column.dataField !== 'lookup' && column.dataField !== 'phoneNumber') {
                    columns.push(column);
                }
            });
            this.messageService.publish({ name, data, context, columns });
        },
        findAllSelectedRows: function() {
            const selectedRows = this.dataGridInstance.instance.getSelectedRowsData();
            if (selectedRows.length) {
                this.promiseAll = [];
                this.messageService.publish({name: 'showPagePreloader'});
                selectedRows.forEach(row => {
                    const queryPromise = new Promise((resolve) => {
                        let executeQuery = {
                            queryCode: 'h_ButtonTransferred',
                            parameterValues: [
                                {key: '@Id', value: row.Id},
                                {key: '@comment', value: row.comment}
                            ],
                            limit: -1
                        };
                        this.queryExecutor(executeQuery, this.changeRowDataCallBack.bind(this, resolve), this);
                    });
                    this.promiseAll.push(queryPromise);
                });
                Promise.all(this.promiseAll).then(() => {
                    this.promiseAll = [];
                    this.dataGridInstance.instance.deselectAll();
                    this.loadData(this.afterLoadDataHandler);
                    this.hideTable();
                    this.messageService.publish({
                        name: 'reloadMainTable'
                    });
                });
            }
        },
        hideTable: function() {
            this.setVisibilityTableContainer('none');
        },
        changeRowDataCallBack: function(resolve, data) {
            resolve(data);
        },
        afterLoadDataHandler: function() {
            this.render();
        },
        afterRenderTable: function() {
            this.messageService.publish({ name: 'afterRenderTable', code: this.config.query.code });
        },
        createElement: function(tag, props, ...children) {
            const element = document.createElement(tag);
            Object.keys(props).forEach(key => element[key] = props[key]);
            if(children.length > 0) {
                children.forEach(child =>{
                    element.appendChild(child);
                });
            } return element;
        }
    };
}());
