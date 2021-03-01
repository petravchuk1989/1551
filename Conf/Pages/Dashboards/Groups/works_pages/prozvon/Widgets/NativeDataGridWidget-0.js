(function() {
    return {
        config: {
            query: {
                code: 'Prozvon_table_v2',
                parameterValues: [ ],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [
                {
                    dataField: 'registration_number',
                    caption: 'Номер'
                }, {
                    dataField: 'registration_date',
                    caption: 'Дата надходження',
                    width: 200
                },{
                    dataField: 'QuestionType',
                    caption: 'Тип питання',
                    width: 200
                }, {
                    dataField: 'full_name',
                    caption: 'Заявник'
                }, {
                    dataField: 'phone_number',
                    caption: 'Телефон'
                }, {
                    dataField: 'cc_nedozvon',
                    caption: 'НДЗ',
                    width: 50
                }, {
                    dataField: 'District',
                    caption: 'Район'
                }, {
                    dataField: 'house',
                    caption: 'БУДИНОК ТА КВАРТИРА'
                }, {
                    dataField: 'entrance',
                    caption: 'П'
                }, {
                    dataField: 'place_problem',
                    caption: 'МІСЦЕ ПРОБЛЕМИ'
                }, {
                    dataField: 'vykon',
                    caption: 'Виконавець'
                }
            ],
            allowColumnResizing: true,
            columnResizingMode: 'widget',
            columnMinWidth: 50,
            keyExpr: 'rn',
            columnAutoWidth: true,
            allowColumnReordering: true,
            pager: {
                showPageSizeSelector: true,
                allowedPageSizes: [10, 50, 100],
                showInfo: true
            },
            paging: {
                pageSize: 100
            },
            export: {
                enabled: false,
                fileName: 'File_name'
            },
            sorting: {
                mode: 'multiple'
            },
            selection: {
                mode: 'multiple'
            },
            masterDetail: {
                enabled: true
            },
            columnFixing: {
                enabled: true
            },
            showBorders: false,
            showColumnLines: false,
            showRowLines: true,
            wordWrapEnabled: true
        },
        createDGButtons: function(e) {
            let toolbarItems = e.toolbarOptions.items;
            toolbarItems.push({
                widget: 'dxButton',
                options: {
                    icon: 'refresh',
                    type: 'default',
                    text: 'Очистити сортування',
                    onClick: function(e) {
                        e.event.stopImmediatePropagation();
                        this.sortingArr = [];
                        this.config.query.parameterValues = [
                            { key: '@filter', value: this.macrosValue },
                            { key: '@sort', value:  '1=1' }
                        ];
                        this.loadData(this.afterLoadDataHandler);
                    }.bind(this)
                },
                location: 'before'
            });
            toolbarItems.push({
                widget: 'dxButton',
                options: {
                    icon: 'close',
                    type: 'default',
                    text: 'Закрити',
                    onClick: function(e) {
                        e.event.stopImmediatePropagation();
                        this.openModalCloserForm();
                    }.bind(this)
                },
                location: 'after'
            });
        },
        init: function() {
            this.dataGridInstance.height = window.innerHeight - 150;
            this.sort = '1=1';
            this.macrosValue = '1=1';
            let executeQuery = {
                queryCode: 'es_show_user_phone_v2',
                limit: -1,
                parameterValues: []
            };
            this.queryExecutor(executeQuery, this.setUserPhoneNumber, this);
            this.showPreloader = false;
            this.sortingArr = [];
            this.sub = this.messageService.subscribe('GlobalFilterChanged', this.setFiltersValue, this);
            this.sub1 = this.messageService.subscribe('ApplyGlobalFilters', this.findAllCheckedFilter, this);
            this.sub2 = this.messageService.subscribe('reloadMainTable', this.reloadMainTable, this);
            this.config.onToolbarPreparing = this.createDGButtons.bind(this);
            this.config.masterDetail.template = this.createMasterDetails.bind(this);
            this.config.onOptionChanged = this.onOptionChanged.bind(this);
            this.dataGridInstance.onCellClick.subscribe(function(e) {
                if(e.column) {
                    if(e.column.dataField === 'full_name' && e.row !== undefined) {
                        window.open(String(location.origin + localStorage.getItem('VirtualPath') +
                        '/dashboard/page/prozvonApplicant?id=' + e.data.ApplicantsId));
                    }else if(e.column.dataField === 'house' && e.row !== undefined) {
                        window.open(String(location.origin + localStorage.getItem('VirtualPath') +
                        '/dashboard/page/prozvonHouse?id=' + e.data.BuildingId));
                    }else if(e.column.dataField === 'registration_number' && e.row !== undefined) {
                        window.open(String(location.origin + localStorage.getItem('VirtualPath') +
                        '/sections/Assignments/edit/' + e.data.Id));
                    }else if(e.column.dataField === 'phone_number' && e.row !== undefined) {
                        let CurrentUserPhone = e.row.data.phone_number;
                        let PhoneForCall = this.userPhoneNumber;
                        let xhr = new XMLHttpRequest();
                        xhr.open('GET', 'https://cc.1551.gov.ua:5566/CallService/Call/number=' +
                        CurrentUserPhone + '&operator=' + PhoneForCall);
                        xhr.send();
                    }
                }
            }.bind(this));
            this.config.query.parameterValues = [
                { key: '@filter', value: this.macrosValue },
                { key: '@sort', value: this.sort }
            ];
            this.loadData(this.afterLoadDataHandler);
        },
        onOptionChanged: function(args) {
            let columnCode;
            if(args.fullName !== undefined) {
                switch (args.fullName) {
                    case('columns[0].sortOrder'):
                        columnCode = 'registration_number'
                        break;
                    case('columns[1].sortOrder'):
                        columnCode = 'registration_date'
                        break;
                    case('columns[2].sortOrder'):
                        columnCode = 'QuestionType'
                        break;
                    case('columns[3].sortOrder'):
                        columnCode = 'full_name'
                        break;
                    case('columns[4].sortOrder'):
                        columnCode = 'phone_number'
                        break;
                    case('columns[5].sortOrder'):
                        columnCode = 'cc_nedozvon'
                        break;
                    case('columns[6].sortOrder'):
                        columnCode = 'District'
                        break;
                    case('columns[7].sortOrder'):
                        columnCode = 'house'
                        break;
                    case('columns[8].sortOrder'):
                        columnCode = 'entrance'
                        break;
                    case('columns[9].sortOrder'):
                        columnCode = 'place_problem'
                        break;
                    case('columns[10].sortOrder'):
                        columnCode = 'vykon'
                        break;
                    case('dataSource'):
                        columnCode = 'dataSource'
                        break;
                    default:
                        break;
                }
                if(columnCode !== undefined) {
                    if(columnCode !== 'dataSource') {
                        const infoColumn = { name: columnCode, value: args.value };
                        if(this.sortingArr.length === 0) {
                            this.sortingArr.push(infoColumn);
                        }else{
                            const index = this.sortingArr.findIndex(x => x.name === columnCode);
                            if(index === -1) {
                                this.sortingArr.push(infoColumn);
                            }else{
                                this.sortingArr.splice(index, 1);
                                this.sortingArr.push(infoColumn);
                            }
                        }
                        this.messageService.publish({ name: 'sortingArr', arr: this.sortingArr });
                    }
                }
            }
        },
        setUserPhoneNumber: function(data) {
            const indexPhoneNumber = data.columns.findIndex(el => el.code.toLowerCase() === 'phonenumber');
            this.userPhoneNumber = data.rows[0].values[indexPhoneNumber];
        },
        openModalCloserForm: function() {
            let rowsMessage = [];
            let selectedRows = [];
            selectedRows = this.dataGridInstance.instance.getSelectedRowsData();
            selectedRows.forEach(row => {
                let obj = {
                    id: row.Id,
                    organization_id: row.Organizations_Id
                }
                rowsMessage.push(obj);
            });
            if (selectedRows.length) {
                this.messageService.publish({ name: 'openModalForm', value: rowsMessage });
            }
        },
        createMasterDetails: function(container, options) {
            let currentEmployeeData = options.data;
            let lastNdzTime;
            if(currentEmployeeData.comment === null) {
                currentEmployeeData.comment = '';
            }
            if(currentEmployeeData.history === null) {
                currentEmployeeData.history = '';
            }
            if(currentEmployeeData.zmist === null) {
                currentEmployeeData.zmist = '';
            }
            if(currentEmployeeData.cc_nedozvon === null) {
                currentEmployeeData.cc_nedozvon = '';
            }
            if(currentEmployeeData.edit_date === null) {
                lastNdzTime = ''
            }else{
                lastNdzTime = this.changeDateTimeValues(currentEmployeeData.edit_date);
            }
            if(currentEmployeeData.control_comment === null) {
                currentEmployeeData.control_comment = '';
            }
            if(currentEmployeeData.All_NDZV === null) {
                currentEmployeeData.All_NDZV = '';
            }
            
            let ndz = currentEmployeeData.cc_nedozvon;
            let ndzComment = currentEmployeeData.control_comment;
/////////////////////////////////////////////////////////
            let AllNDZV = currentEmployeeData.All_NDZV;
           
            let elementHistoryAllNDZV__content = this.createElement(
                'div',
                {
                    className: 'elementHistoryAllNDZV__content content',
                    innerHTML: AllNDZV 
                }
            );

            let elementHistoryAllNDZV__caption = this.createElement('div', { className: 'elementHistoryAllNDZV__caption caption', innerText: 'Історія'});
            let elementHistoryAllNDZV = this.createElement(
                'div',
                {
                    className: 'elementHistoryAllNDZV element'
                },
                elementHistoryAllNDZV__caption, elementHistoryAllNDZV__content
            );

////////////////////////////////////////////////////////////////
            let elementHistory__content = this.createElement(
                'div',
                {
                    className: 'elementHistory__content content',
                    innerText: ndz + ' ( дата та час останнього недозвону: ' + lastNdzTime + '), коментар: ' + ndzComment
                }
            );
            let elementHistory__caption = this.createElement('div', { className: 'elementHistory__caption caption', innerText: 'Історія_останній НДЗ'});
            let elementHistory = this.createElement(
                'div',
                {
                    className: 'elementHistory element'
                },
                elementHistory__caption, elementHistory__content
            );
            let elementСontent__content = this.createElement(
                'div',
                {
                    className: 'elementСontent__content content',
                    innerText: String(String(currentEmployeeData.zmist))
                }
            );
            let elementСontent__caption = this.createElement('div', { className: 'elementСontent__caption caption', innerText: 'Зміст'});
            let elementСontent = this.createElement(
                'div',
                {
                    className: 'elementСontent element'
                },
                elementСontent__caption,elementСontent__content
            );
            let elementComment__content = this.createElement(
                'div',
                {
                    className: 'elementComment__content content',
                    innerText: String(String(currentEmployeeData.comment))
                }
            );
            let elementComment__caption = this.createElement(
                'div',
                {
                    className: 'elementComment__caption caption',
                    innerText: 'Коментар виконавця'
                }
            );
            let elementComment = this.createElement(
                'div',
                {
                    className: 'elementСontent element'
                },
                elementComment__caption, elementComment__content
            );
            let elementsWrapper = this.createElement(
                'div',
                {
                    className: 'elementsWrapper'
                },
                elementHistoryAllNDZV, elementHistory, elementСontent, elementComment
            );
            container.appendChild(elementsWrapper);
            let elementsAll = document.querySelectorAll('.element');
            elementsAll = Array.from(elementsAll);
            elementsAll.forEach(el => {
                el.style.display = 'flex';
                el.style.margin = '15px 10px';
            });
            let elementsCaptionAll = document.querySelectorAll('.caption');
            elementsCaptionAll = Array.from(elementsCaptionAll);
            elementsCaptionAll.forEach(el => {
                el.style.minWidth = '200px';
            });
        },
        changeDateTimeValues: function(value) {
            let date = new Date(value);
            let dd = date.getDate().toString();
            let mm = (date.getMonth() + 1).toString();
            let yyyy = date.getFullYear().toString();
            let HH = date.getHours().toString();
            let MM = date.getMinutes().toString();
            dd = dd.length === 1 ? '0' + dd : dd;
            mm = mm.length === 1 ? '0' + mm : mm;
            HH = HH.length === 1 ? '0' + HH : HH;
            MM = MM.length === 1 ? '0' + MM : MM;
            return `${dd}.${mm}.${yyyy} ${HH}:${MM}`;
        },
        afterLoadDataHandler: function() {
            this.render();
        },
        setFiltersValue:function(message) {
            this.filtersValues = [];
            this.filtersValuesMacros = [];
            let filters = message.package.value.values;
            filters.forEach(elem => {
                if(elem.active === true) {
                    let data = elem.value;
                    if(typeof (data) === 'boolean') {
                        this.createObjMacros(elem.name, '=', 'true', elem.placeholder);
                    }else if(typeof (data) === 'object') {
                        if(data[0]) {
                            if(typeof (data[0].value) === 'number') {
                                if(elem.name === 'zayavnyk_age') {
                                    this.ageArr = [];
                                    let ageSendViewValue = '';
                                    data.forEach(el => {
                                        let values = el.viewValue.split('-');
                                        let ageValue = '(zayavnyk_age>=' + values[0] + ' and zayavnyk_age<=' + values[1] + ')';
                                        this.ageArr.push(ageValue);
                                        ageSendViewValue = ageSendViewValue + ', ' + el.viewValue;
                                    });
                                    ageSendViewValue = ageSendViewValue.slice(2, [ageSendViewValue.length]);
                                    let ageSendValue = this.ageArr.join(' or ');
                                    ageSendValue = '(' + ageSendValue + ')';
                                    this.createObjMacros(elem.name, '===', ageSendValue, elem.placeholder, ageSendViewValue);
                                }else{
                                    let sumValue = '';
                                    let sumViewValue = '';
                                    if(data.length > 0) {
                                        data.forEach(row => {
                                            sumValue = sumValue + ', ' + row.value;
                                            sumViewValue = sumViewValue + ', ' + row.viewValue;
                                        });
                                    }
                                    let numberSendValue = sumValue.slice(2, [sumValue.length]);
                                    let numberSendViewValue = sumViewValue.slice(2, [sumViewValue.length]);
                                    this.createObjMacros(elem.name, 'in', numberSendValue, elem.placeholder, numberSendViewValue);
                                }
                            }else if(typeof (data[0].value) === 'string') {
                                let stringSumValue = '';
                                let stringSumViewValue = '';
                                if(data.length > 0) {
                                    data.forEach(row => {
                                        stringSumValue = stringSumValue + ', \'' + row.value + '\'';
                                        stringSumViewValue = stringSumViewValue + ', ' + row.viewValue;
                                    });
                                }
                                let stringSendValue = stringSumValue.slice(2, [stringSumValue.length]);
                                let stringSendViewValue = stringSumViewValue.slice(2, [stringSumViewValue.length]);
                                this.createObjMacros(elem.name, 'in', stringSendValue, elem.placeholder, stringSendViewValue);
                            }
                        }else if(data.value && data.viewValue) {
                            this.createObjMacros(elem.name, 'in', data.value, elem.placeholder, data.viewValue);
                        }else{
                            if(data.dateFrom !== '') {
                                this.createObjMacros(
                                    'cast(' + elem.name + ' as datetime)',
                                    '>=',
                                    checkDateFrom(elem.value),
                                    elem.placeholder,
                                    elem.value.viewValue
                                );
                                switch (elem.name) {
                                    case 'registration_date':
                                        this.registrationDate__from = checkDateFrom(elem.value);
                                        this.registrationDateFrom = checkDateFrom(elem.value);
                                        break;
                                    case 'transfer_date':
                                        this.transferDateFrom = checkDateFrom(elem.value);
                                        break;
                                    case 'state_changed_date':
                                        this.stateChangedDateFrom = checkDateFrom(elem.value);
                                        break;
                                    case 'state_changed_date_done':
                                        this.stateChangedDateDoneFrom = checkDateFrom(elem.value);
                                        break;
                                    case 'execution_term':
                                        this.executionTermFrom = checkDateFrom(elem.value);
                                        break;
                                    default:
                                        break;
                                }
                            }
                            if(data.dateTo !== '') {
                                this.createObjMacros(
                                    'cast(' + elem.name + ' as datetime)',
                                    '<=',
                                    checkDateTo(elem.value),
                                    elem.placeholder,
                                    elem.value.viewValue
                                );
                                switch (elem.name) {
                                    case 'registration_date':
                                        this.registrationDateTo = checkDateTo(elem.value);
                                        break;
                                    case 'transfer_date':
                                        this.transferDateTo = checkDateTo(elem.value);
                                        break;
                                    case 'state_changed_date':
                                        this.stateChangedDateTo = checkDateTo(elem.value);
                                        break;
                                    case 'state_changed_date_done':
                                        this.stateChangedDateDoneTo = checkDateTo(elem.value);
                                        break;
                                    case 'execution_term':
                                        this.executionTermTo = checkDateTo(elem.value);
                                        break;
                                    default:
                                        break;
                                }
                            }
                        }
                    }else if(typeof (data) === 'string') {
                        this.createObjMacros(elem.name, 'like', elem.value, elem.placeholder, elem.value.viewValue);
                    }
                }
            });
            function checkDateFrom(val) {
                return val ? val.dateFrom : null;
            }
            function checkDateTo(val) {
                return val ? val.dateTo : null;
            }
        },
        createObjMacros: function(name, operation, value, placeholder, viewValue) {
            let obj = {
                code: name,
                operation: operation,
                value: value,
                placeholder: placeholder,
                viewValue: viewValue
            }
            this.filtersValuesMacros.push(obj);
        },
        createFilterMacros: function(code, operation, currentDate) {
            let textMacros = '';
            if(operation === 'like') {
                textMacros = `${String(code)} ${operation} '%${currentDate}%'`;
            }else if(operation === '===') {
                textMacros = `${String(currentDate)}`;
            }else if(operation === '==') {
                textMacros = `${String(code)} = ${currentDate}`;
            }else if(operation === '+""+') {
                textMacros = `${String(code)} in  (N'${currentDate}'`;
            }else if(operation === 'in') {
                textMacros = `${String(code)} in (${currentDate})`;
            }else if(operation === '=') {
                textMacros = `${String(code)} ${operation} N'${currentDate}'`;
            }else if(operation === '>=' || operation === '<=') {
                let dd = currentDate.getDate().toString();
                let mm = (currentDate.getMonth() + 1).toString();
                let yyyy = currentDate.getFullYear().toString();
                let HH = currentDate.getHours().toString();
                let MM = currentDate.getMinutes().toString();
                dd = dd.length === 1 ? '0' + dd : dd;
                mm = mm.length === 1 ? '0' + mm : mm;
                HH = HH.length === 1 ? '0' + HH : HH;
                MM = MM.length === 1 ? '0' + MM : MM;
                const time = `${yyyy}-${mm}-${dd} ${HH}:${MM}`;
                textMacros = `${String(code)} ${operation} N'${time}'`;
            }
            this.textFilterMacros.push(textMacros);
        },
        findAllCheckedFilter: function() {
            this.sendMsgForSetFilterPanelState(false);
            if(this.filtersValuesMacros.length) {
                this.textFilterMacros = [];
                this.filtersValuesMacros.forEach(filter => this.createFilterMacros(filter.code, filter.operation, filter.value));
                this.macrosValue = this.textFilterMacros.join(' and ');
            }else{
                this.macrosValue = '1=1';
            }
            this.config.query.parameterValues = [
                { key: '@filter', value: this.macrosValue },
                { key: '@sort', value: this.sort }
            ];
            this.loadData(this.afterLoadDataHandler);
        },
        sendMsgForSetFilterPanelState: function(state) {
            const msg = {
                name: 'SetFilterPanelState',
                package: {
                    value: state
                }
            };
            this.messageService.publish(msg);
        },
        setFilterColumns: function(code, operation, value) {
            const filter = {
                key: code,
                value: {
                    operation: operation,
                    not: false,
                    values: value
                }
            };
            this.config.query.filterColumns.push(filter);
        },
        reloadTable: function(message) {
            message.value.forEach(el => {
                let column = {
                    dataField: el.displayValue,
                    caption: el.caption,
                    width: el.width
                }
                this.config.columns.push(column)
            });
            this.loadData(this.afterLoadDataHandler);
        },
        reloadMainTable: function(message) {
            this.dataGridInstance.instance.deselectAll();
            this.sort = message.sortingString;
            this.config.query.parameterValues = [
                { key: '@filter', value: this.macrosValue },
                { key: '@sort', value:  this.sort }
            ];
            this.loadData(this.afterLoadDataHandler);
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
        destroy: function() {
            this.sub.unsubscribe();
            this.sub1.unsubscribe();
            this.sub2.unsubscribe();
        }
    };
}());
