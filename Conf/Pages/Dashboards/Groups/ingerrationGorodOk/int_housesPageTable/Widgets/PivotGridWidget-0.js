(function() {
    return {
        config: {
            query: {
                code: 'int_housesPageTable',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns:[
                {
                    dataField: 'operation',
                    caption: 'Операція',
                    width: 120,
                    alignment: 'center'
                },{
                    caption: 'ГородОк',
                    alignment: 'center',
                    columns: [
                        { caption: 'Було',
                            alignment: 'center',
                            columns:[
                                {
                                    dataField: 'become_district_name',
                                    caption: 'Район',
                                    alignment: 'center',
                                    width: 140
                                },{
                                    dataField: 'become',
                                    caption: 'Будинок',
                                    alignment: 'center'
                                }]
                        },
                        { caption: 'Стало',
                            alignment: 'center',
                            columns:[
                                {
                                    dataField: 'it_was_district_name',
                                    caption: 'Район',
                                    width: 140,
                                    alignment: 'center'
                                },{
                                    dataField: 'it_was',
                                    caption: 'Будинок',
                                    alignment: 'center'
                                }]
                        }
                    ]
                },{
                    caption: '1551',
                    alignment: 'center',
                    columns:[
                        {
                            dataField: 'district_id',
                            alignment: 'center',
                            caption: 'Район',
                            setCellValue: function(rowData, value) {
                                rowData.district_id = value;
                                rowData.id_1551 = null;
                            },
                            lookup: {
                                dataSource: {
                                    paginate: true,
                                    store: this.elements_dis
                                },
                                alignment: 'center',
                                displayExpr: 'name',
                                valueExpr: 'Id'
                            }
                        },{
                            dataField: 'id_1551',
                            alignment: 'center',
                            caption: 'Вулиці у системі 1551',
                            lookup: {
                                dataSource: function(options) {
                                    return{
                                        paginate: true,
                                        store: this.elements,
                                        filter: options.data ? ['district_id', '=', options.data.district_id] : null
                                    }
                                },
                                displayExpr: 'name',
                                valueExpr: 'Id'
                            }
                        }
                    ]
                },{
                    dataField: 'is_done',
                    caption: 'Стан',
                    alignment: 'center',
                    width: 100
                },{
                    dataField: 'comment',
                    alignment: 'center',
                    caption: 'Коментар'
                }
            ],
            searchPanel: {
                visible: true,
                highlightCaseSensitive: false
            },
            pager: {
                showPageSizeSelector:  false,
                allowedPageSizes: [10, 15, 30],
                showInfo: true,
                pageSize: 10
            },
            export: {
                fileName: 'Excel'
            },
            editing: {
                mode: 'batch',
                allowUpdating: true,
                useIcons: true,
                text: [
                    {
                        editRow: 'Editdfdsf',
                        saveAllChanges: 'Save changes 123',
                        saveRowChanges: 'Save'
                    }
                ]
            },
            onEditorPreparing: function(e) {
                if(e.parentType === 'dataRow' && e.dataField === 'id_1551') {
                    e.editorOptions.disabled = (typeof e.row.data.district_id !== 'number');
                }
            },
            filterRow: {
                visible: true,
                applyFilter: 'auto'
            },
            keyExpr: 'Id',
            showBorders: true,
            showColumnLines: true,
            showRowLines: true,
            remoteOperations: null,
            allowColumnReordering: null,
            rowAlternationEnabled: null,
            columnAutoWidth: null,
            hoverStateEnabled: true,
            columnWidth: null,
            wordWrapEnabled: true,
            allowColumnResizing: true,
            showFilterRow: false,
            showHeaderFilter: false,
            showColumnChooser: true,
            showColumnFixing: true,
            groupingAutoExpandAll: null,
            toolbarPreparing: function(data) {
                let indexSaveButton = data.toolbarOptions.items.indexOf(data.toolbarOptions.items.find(function(item) {
                    return item.name === 'saveButton';
                }));
                if (indexSaveButton !== -1) {
                    data.toolbarOptions.items.splice(indexSaveButton, 1);
                }
                let indexRevertButton = data.toolbarOptions.items.indexOf(data.toolbarOptions.items.find(function(item) {
                    return item.name === 'revertButton';
                }));
                if (indexRevertButton !== -1) {
                    data.toolbarOptions.items.splice(indexRevertButton, 1);
                }
            }
        },
        myFunc: function(options) {
            return{
                paginate: true,
                store: this.elements,
                filter: options.data ? ['district_id', '=', options.data.district_id] : null
            }
        },
        elements: [],
        init: function() {
            this.dataGridInstance.height = window.innerHeight - 100;
            this.promiseAll = [];
            const promiseDistrict = new Promise((resolve) => {
                let executeQuery = {
                    queryCode: 'int_list_district_1551',
                    parameterValues: [],
                    limit: -1
                };
                this.queryExecutor(executeQuery, this.lookupFoo_dis.bind(this, resolve), this);
            });
            this.promiseAll.push(promiseDistrict);
            const promiseHouse = new Promise((resolve) => {
                let executeQuery = {
                    queryCode: 'int_list_houses_1551',
                    parameterValues: [],
                    limit: -1
                };
                this.queryExecutor(executeQuery, this.lookupFoo.bind(this, resolve), this);
            });
            this.promiseAll.push(promiseHouse);
            this.afterApplyAllRequests();
            this.dataGridInstance.onRowUpdating.subscribe(function(e) {
                let is_done = e.newData.is_done;
                let key = e.key;
                let id_1551 = e.oldData.id_1551;
                let id_1551_new = e.newData.id_1551;
                let comment = e.newData.comment;
                let cat_id = e.oldData.cat_id;
                let saveChange = {
                    queryCode: 'int_btnSaveChange_housesGorodok',
                    limit: -1,
                    parameterValues: [
                        {
                            key: '@key',
                            value: key
                        },{
                            key: '@is_done',
                            value: is_done
                        },{
                            key: '@id_1551',
                            value: id_1551
                        },{
                            key: '@id_1551_new',
                            value: id_1551_new
                        },{
                            key: '@comment',
                            value: comment
                        },{
                            key: '@cat_id',
                            value: cat_id
                        }
                    ]
                };
                this.queryExecutor(saveChange);
            }.bind(this));
            this.config.onToolbarPreparing = this.createTableButton.bind(this);
        },
        lookupFoo_dis: function(resolve, data) {
            this.elements_dis = [];
            for(let i = 0; i < data.rows.length; i++) {
                let el = data.rows[i];
                let obj = {
                    'Id': el.values[0],
                    'name': el.values[1]
                }
                this.elements_dis.push(obj);
            }
            this.config.columns[2].columns[0].lookup.dataSource.store = this.elements_dis;
            resolve(data);
        },
        lookupFoo: function(resolve, data) {
            this.elements = [];
            for(let i = 0; i < data.rows.length; i++) {
                let el = data.rows[i];
                let obj = {
                    'Id': el.values[0],
                    'name': el.values[1],
                    'district_id': el.values[2]
                }
                this.elements.push(obj);
            }
            this.config.columns[2].columns[1].lookup.dataSource.store = this.elements;
            this.config.columns[2].columns[1].lookup.dataSource = this.myFunc.bind(this);
            resolve(data);
        },
        afterApplyAllRequests: function() {
            Promise.all(this.promiseAll).then(() => {
                this.promiseAll = [];
                this.dataGridInstance.instance.deselectAll();
                this.loadData(this.afterLoadDataHandler);
            });
        },
        createTableButton: function(e) {
            let toolbarItems = e.toolbarOptions.items;
            toolbarItems[0].showText = ''
            toolbarItems[0].options.text = 'Зберегти'
            toolbarItems[0].options.type = 'default'
            toolbarItems.push({
                widget: 'dxButton',
                options: {
                    icon: 'exportxlsx',
                    type: 'default',
                    text: 'Excel',
                    onClick: function() {
                        this.dataGridInstance.instance.exportToExcel();
                    }.bind(this)
                },
                location: 'after'
            });
        },
        afterLoadDataHandler: function() {
            this.render();
        }
    };
}());
