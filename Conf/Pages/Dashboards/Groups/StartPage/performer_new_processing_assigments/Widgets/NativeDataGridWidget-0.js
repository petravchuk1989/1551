(function() {
    return {
        config: {
            query: {
                code: 'Nadiyshlo_686',
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
                    width: 150
                }, {
                    dataField: 'ass_registration_date',
                    caption: 'Дата надходження',
                    dataType: 'datetime',
                    format: 'dd.MM.yyyy HH:mm'
                }, {
                    dataField: 'QuestionType',
                    caption: 'Тип питання'
                }, {
                    dataField: 'zayavnyk',
                    caption: 'Заявник'
                }, {
                    dataField: 'adress',
                    caption: 'Місце проблеми'
                }, {
                    dataField: 'control_date',
                    caption: 'Дата контролю',
                    dataType: 'datetime',
                    format: 'dd.MM.yyyy HH:mm'
                }, {
                    dataField: 'transfer_to_organization_id',
                    caption: 'Виконавець',
                    lookup: {
                        dataSource: {
                            paginate: true,
                            store: this.elements
                        },
                        valueExpr: 'ID',
                        displayExpr: 'Name'
                    }
                }
            ],
            masterDetail: {
                enabled: true
            },
            filterRow: {
                visible: true,
                applyFilter: 'auto'
            },
            export: {
                enabled: false,
                fileName: 'Excel'
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
            editing: {
                mode: 'cell',
                allowUpdating: true,
                useIcons: true
            },
            selection:{
                mode: 'multiple'
            },
            sorting: {
                mode: 'multiple'
            },
            focusedRowEnabled: true,
            keyExpr: 'Id',
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
            showColumnFixing: true
        },
        init: function() {
            const context = this;
            this.messageService.publish({ name: 'checkDisplayWidth', context});
            document.getElementById('table41__arrived').style.display = 'none';
            this.sub = this.messageService.subscribe('clickOnTable2', this.changeOnTable, this);
            this.sub1 = this.messageService.subscribe('messageWithOrganizationId', this.orgIdDistribute, this);
            this.changedRows = [];
            this.config.onToolbarPreparing = this.createTableButton.bind(this);
            this.config.masterDetail.template = this.createMasterDetail.bind(this);
            this.dataGridInstance.onCellClick.subscribe(e => {
                if(e.column) {
                    if(e.column.dataField === 'registration_number' && e.row !== undefined) {
                        window.open(String(
                            location.origin +
                            localStorage.getItem('VirtualPath') +
                            '/sections/Assignments/edit/' + e.key
                        ));
                    }
                }
            });
            this.config.onContentReady = this.afterRenderTable.bind(this);
        },
        exportToExcel: function() {
            let exportQuery = {
                queryCode: this.config.query.code,
                limit: -1,
                parameterValues: [
                    { key: '@organization_id', value: this.orgId},
                    { key: '@organizationName', value: this.orgName},
                    { key: '@navigation', value: this.navigator}
                ]
            };
            this.queryExecutor(exportQuery, this.myCreateExcel, this);
        },
        myCreateExcel: function(data) {
            this.showPagePreloader('Зачекайте, формується документ');
            this.indexArr = [];
            let column_registration_number = { name: 'registration_number', index: 0 };
            let column_zayavnyk = { name: 'zayavnyk', index: 1 };
            let column_QuestionType = { name: 'QuestionType', index: 2 };
            let column_vykonavets = { name: 'vykonavets', index: 3 };
            let column_adress = { name: 'adress', index: 4 };
            this.indexArr = [
                column_registration_number,
                column_zayavnyk,
                column_QuestionType,
                column_vykonavets,
                column_adress
            ];
            const workbook = this.createExcel();
            const worksheet = workbook.addWorksheet('Заявки', {
                pageSetup:{
                    orientation: 'landscape',
                    fitToPage: false
                }
            });
            worksheet.pageSetup.margins = {
                left: 0.4, right: 0.3,
                top: 0.4, bottom: 0.4,
                header: 0.0, footer: 0.0
            };
            let cellInfoCaption = worksheet.getCell('A1');
            cellInfoCaption.value = 'Інформація';
            let cellInfo = worksheet.getCell('A2');
            cellInfo.value =
                'про звернення громадян, що надійшли до Контактного центру  міста Києва. Термін виконання …';
            let cellPeriod = worksheet.getCell('A3');
            cellPeriod.value = 'Період вводу з (включно) : дата з … дата по … .';
            let cellNumber = worksheet.getCell('A4');
            cellNumber.value = 'Реєстраційний № РДА …';
            worksheet.mergeCells('A1:F1');
            worksheet.mergeCells('A2:F2');
            worksheet.mergeCells('A3:F3');
            worksheet.getRow(1).font = {
                name: 'Times New Roman',
                family: 4,
                size: 10,
                underline: false,
                bold: true,
                italic: false
            };
            worksheet.getRow(1).alignment = { vertical: 'middle', horizontal: 'center' };
            worksheet.getRow(2).font = {
                name: 'Times New Roman',
                family: 4,
                size: 10,
                underline: false,
                bold: true,
                italic: false
            };
            worksheet.getRow(2).alignment = { vertical: 'middle', horizontal: 'center' };
            worksheet.getRow(3).font = {
                name: 'Times New Roman',
                family: 4,
                size: 10,
                underline: false,
                bold: true,
                italic: false
            };
            worksheet.getRow(3).alignment = { vertical: 'middle', horizontal: 'left' };
            worksheet.getRow(4).font = {
                name: 'Times New Roman',
                family: 4,
                size: 10,
                underline: false,
                bold: true,
                italic: false
            };
            worksheet.getRow(4).alignment = { vertical: 'middle', horizontal: 'left' };
            let indexArr = this.indexArr;
            let rows = [];
            let captions = [];
            let columnsHeader = [];
            let columnNumber = { key: 'number', width: 5 }
            columnsHeader.push(columnNumber);
            let rowNumber = '№ з/п';
            captions.push(rowNumber);
            indexArr.forEach(el => {
                let obj = {}
                if (el.name === 'registration_number') {
                    obj.key = 'registration_number';
                    obj.width = 10;
                    obj.height = 20;
                    captions.push('Номер, дата, час');
                } else if(el.name === 'QuestionType') {
                    obj.key = 'QuestionType';
                    obj.width = 44;
                    captions.push('Суть питання');
                } else if(el.name === 'zayavnyk') {
                    obj.key = 'zayavnyk';
                    obj.width = 30;
                    captions.push('Заявник');
                } else if(el.name === 'vykonavets') {
                    obj.key = 'vykonavets';
                    obj.width = 16;
                    captions.push('Виконавець');
                } else if(el.name === 'adress') {
                    obj.key = 'adress';
                    obj.width = 21;
                    captions.push('Місце проблеми (Об\'єкт)');
                }
                columnsHeader.push(obj);
            });
            worksheet.getRow(5).values = captions;
            worksheet.columns = columnsHeader;
            this.addetedIndexes = [];
            let indexRegistrationNumber = data.columns.findIndex(el => el.code.toLowerCase() === 'registration_number');
            let indexZayavnikName = data.columns.findIndex(el => el.code.toLowerCase() === 'zayavnyk');
            let indexAdress = data.columns.findIndex(el => el.code.toLowerCase() === 'adress');
            let indexVykonavets = data.columns.findIndex(el => el.code.toLowerCase() === 'vykonavets');
            let indexQuestionContent = data.columns.findIndex(el => el.code.toLowerCase() === 'zayavnyk_zmist');
            let indexAdressZ = data.columns.findIndex(el => el.code.toLowerCase() === 'zayavnyk_adress');
            let indexRegistrDate = data.columns.findIndex(el => el.code.toLowerCase() === 'ass_registration_date');
            let indexControlDate = data.columns.findIndex(el => el.code.toLowerCase() === 'control_date');
            for(let j = 0; j < data.rows.length; j++) {
                const row = data.rows[j];
                let rowItem = { number: j + 1 };
                for (let i = 0; i < indexArr.length; i++) {
                    let el = indexArr[i];
                    if (el.name === 'registration_number') {
                        rowItem.registration_number =
                            row.values[indexRegistrationNumber] +
                            ', ' +
                            this.changeDateTimeValues(row.values[indexRegistrDate]);
                    } else if(el.name === 'zayavnyk') {
                        rowItem.zayavnyk = row.values[indexZayavnikName] + ', ' + row.values[indexAdressZ];
                    } else if(el.name === 'QuestionType') {
                        rowItem.QuestionType = 'Зміст: ' + row.values[indexQuestionContent];
                    } else if(el.name === 'vykonavets') {
                        rowItem.vykonavets =
                            row.values[indexVykonavets] +
                            '. Дата контролю:  ' +
                            this.changeDateTimeValues(row.values[indexControlDate]);
                    } else if(el.name === 'adress') {
                        rowItem.adress = row.values[indexAdress];
                    }
                }
                rows.push(rowItem);
            }
            rows.forEach(el => {
                let number = el.number + '.'
                let row = {
                    number: number,
                    registration_number: el.registration_number,
                    zayavnyk: el.zayavnyk,
                    QuestionType: el.QuestionType,
                    vykonavets: el.vykonavets,
                    adress: el.adress
                }
                worksheet.addRow(row);
            });
            for(let i = 0; i < rows.length + 1; i++) {
                let number = i + 5;
                const row = worksheet.getRow(number);
                row.height = 100;
                worksheet.getRow(number).border = {
                    top: {style:'thin'},
                    left: {style:'thin'},
                    bottom: {style:'thin'},
                    right: {style:'thin'}
                };
                worksheet.getRow(number).alignment = {
                    vertical: 'middle',
                    horizontal: 'center',
                    wrapText: true
                };
                worksheet.getRow(number).font = {
                    name: 'Times New Roman',
                    family: 4, size: 10,
                    underline: false,
                    bold: false,
                    italic: false
                };
            }
            worksheet.getRow(2).border = {
                bottom: {style:'thin'}
            };
            worksheet.getRow(5).font = {
                name: 'Times New Roman',
                family: 4,
                size: 10,
                underline: false,
                bold: true,
                italic: false
            };
            worksheet.getRow(5).alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
            this.helperFunctions.excel.save(workbook, 'Заявки', this.hidePagePreloader);
        },
        changeDateTimeValues: function(value) {
            let date = new Date(value);
            let dd = date.getDate();
            let MM = date.getMonth();
            let yyyy = date.getFullYear();
            let HH = date.getUTCHours()
            let mm = date.getMinutes();
            MM += 1;
            if ((dd.toString()).length === 1) {
                dd = '0' + dd;
            }
            if ((MM.toString()).length === 1) {
                MM = '0' + MM;
            }
            if ((HH.toString()).length === 1) {
                HH = '0' + HH;
            }
            if ((mm.toString()).length === 1) {
                mm = '0' + mm;
            }
            let trueDate = dd + '.' + MM + '.' + yyyy;
            return trueDate;
        },
        orgIdDistribute: function(message) {
            this.organizationId = message.value;
            this.distribute = message.distribute;
        },
        createTableButton: function(e) {
            let toolbarItems = e.toolbarOptions.items;
            toolbarItems.push({
                widget: 'dxButton',
                options: {
                    icon: 'exportxlsx',
                    type: 'default',
                    text: 'Excel',
                    onClick: function(e) {
                        e.event.stopImmediatePropagation();
                        this.exportToExcel();
                    }.bind(this)
                },
                location: 'after'
            });
            toolbarItems.push({
                widget: 'dxButton',
                options: {
                    icon: 'upload',
                    type: 'default',
                    text: 'Розподiлити',
                    elementAttr: {
                        id: 'button_ozpodil'
                    },
                    onClick: function(e) {
                        e.event.stopImmediatePropagation();
                        this.findAllSelectRowsRozpodil();
                    }.bind(this)
                },
                location: 'after'
            });
            toolbarItems.push({
                widget: 'dxButton',
                options: {
                    icon: 'check',
                    type: 'default',
                    text: 'Взяти в роботу',
                    elementAttr: {
                        id: 'button_arrived'
                    },
                    onClick: function(e) {
                        e.event.stopImmediatePropagation();
                        this.findAllSelectRowsToArrived();
                    }.bind(this)
                },
                location: 'after'
            });
        },
        createElement: function(tag, props, ...children) {
            const element = document.createElement(tag);
            Object.keys(props).forEach(key => element[key] = props[key]);
            if(children.length > 0) {
                children.forEach(child =>{
                    element.appendChild(child);
                });
            } return element;
        },
        createMasterDetail: function(container, options) {
            const currentEmployeeData = options.data;
            const name = 'createMasterDetail';
            const fields = {
                zayavnyk_adress: 'Адреса заявника',
                zayavnyk_zmist: 'Зміст',
                balans_name: 'Балансоутримувач'
            };
            this.messageService.publish({
                name, currentEmployeeData, fields, container
            });
        },
        changeOnTable: function(message) {
            if(message.column !== 'Надійшло') {
                document.getElementById('table41__arrived').style.display = 'none';
            }else if (this.distribute === 1) {
                this.column = message.column;
                this.navigator = message.navigation;
                this.targetId = message.targetId;
                this.orgId = message.orgId;
                this.orgName = message.orgName;
                document.getElementById('table41__arrived').style.display = 'block';
                this.config.query.parameterValues = [{ key: '@organization_id', value: message.orgId},
                    { key: '@organizationName', value: message.orgName},
                    { key: '@navigation', value: message.navigation}];
                let executeQuery = {
                    queryCode: 'Lookup_NeVKompetencii_PidOrganization',
                    parameterValues: [ {key: '@organization_id', value: this.organizationId} ],
                    limit: -1
                };
                this.queryExecutor(executeQuery, this.lookupFoo, this);
            }
        },
        lookupFoo: function(data) {
            this.elements = [];
            for(let i = 0; i < data.rows.length; i++) {
                let el = data.rows[i];
                let obj = {
                    'ID': el.values[0],
                    'Name': el.values[1]
                }
                this.elements.push(obj);
            }
            this.config.columns[6].lookup.dataSource.store = this.elements;
            this.loadData(this.afterLoadDataHandler);
        },
        findAllSelectRowsToArrived: function() {
            let rows = this.dataGridInstance.selectedRowKeys;
            if(rows.length > 0) {
                let arrivedSendValueRows = rows.join(', ');
                let executeQuery = {
                    queryCode: 'Button_Nadiishlo_VzyatyVRobotu',
                    parameterValues: [ {key: '@Ids', value: arrivedSendValueRows} ],
                    limit: -1
                };
                this.queryExecutor(executeQuery);
                this.loadData(this.afterLoadDataHandler);
                this.messageService.publish({
                    name: 'reloadMainTable',
                    column: this.column,
                    navigator: this.navigator,
                    targetId: this.targetId
                });
            }
        },
        findAllSelectRowsRozpodil: function() {
            let rows = this.dataGridInstance.instance.getSelectedRowsData();
            if(rows.length > 0) {
                rows.forEach(function(el) {
                    let executeQuery = {
                        queryCode: 'Button_Nadiishlo_Rozpodility',
                        parameterValues: [ {key: '@executor_organization_id', value: el.transfer_to_organization_id},
                            {key: '@Id', value: el.Id},
                            {key: '@current_edit_date', value: el.edit_date} ],
                        limit: -1
                    };
                    this.queryExecutor(executeQuery);
                }.bind(this));
                this.loadData(this.afterLoadDataHandler);
                this.messageService.publish({
                    name: 'reloadMainTable',
                    column: this.column,
                    navigator: this.navigator,
                    targetId: this.targetId
                });
            }
        },
        reloadAfterSend: function() {
            this.loadData(this.afterLoadDataHandler);
        },
        afterLoadDataHandler: function() {
            this.render();
        },
        afterRenderTable: function() {
            let elements = document.querySelectorAll('.dx-datagrid-export-button');
            elements = Array.from(elements);
            elements.forEach(function(element) {
                let spanElement = this.createElement('span', { className: 'dx-button-text', innerText: 'Excel'});
                element.firstElementChild.appendChild(spanElement);
            }.bind(this));
        },
        destroy: function() {
            this.sub.unsubscribe();
            this.sub1.unsubscribe();
        }
    };
}());
