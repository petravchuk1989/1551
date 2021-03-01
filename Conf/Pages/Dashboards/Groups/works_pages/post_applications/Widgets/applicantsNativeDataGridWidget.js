(function() {
    return {
        config: {
            query: {
                code: 'h_JA_MainTable',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [
                {
                    dataField: 'Registration_Number',
                    caption: 'Номер'
                },
                {
                    dataField: 'Registration_date',
                    caption: 'Дата реєстації'
                },
                {
                    dataField: 'AssignmentState',
                    caption: 'Стан',
                    alignment: 'center'
                },
                {
                    dataField: 'QuestionType',
                    caption: 'Тип питання'
                },
                {
                    dataField: 'Place_Problem',
                    caption: 'Місце проблеми'
                },
                {
                    dataField: 'Control_Date',
                    caption: 'Дата контролю'
                },
                {
                    dataField: 'Positions_Name',
                    caption: 'Виконавець'
                },
                {
                    dataField: 'Comment',
                    caption: 'Коментар'
                }
            ],
            filterRow: {
                visible: true,
                applyFilter: 'auto'
            },
            masterDetail: {
                enabled: true
            },
            selection: {
                mode: 'multiple'
            },
            keyExpr: 'Id',
            allowColumnResizing: true,
            columnAutoWidth: false,
            hoverStateEnabled: true,
            pager: {
                showPageSizeSelector: true,
                allowedPageSizes: [10, 20, 50]
            },
            paging: {
                pageSize: 10
            },
            wordWrapEnabled: true,
            showFilterRow: true,
            showHeaderFilter: true,
            showBorders: false,
            showColumnLines: false,
            showRowLines: true
        },
        init: function() {
            this.dataGridInstance.height = window.innerHeight - 350;
            const phoneNumber = this.getUrlParams();
            this.executeExecutorApplicantsQuery(phoneNumber);
            this.config.masterDetail.template = this.createMasterDetail.bind(this);
            this.config.onToolbarPreparing = this.createDGButtons.bind(this);
            this.config.onCellPrepared = this.onCellPrepared.bind(this);
            this.subscribers.push(this.messageService.subscribe('reloadMainTable', this.reloadMainTable, this));
            this.dataGridInstance.onCellClick.subscribe(function(e) {
                if (e.column) {
                    if (e.column.dataField === 'Registration_Number') {
                        window.open(
                            location.origin +
                            localStorage.getItem('VirtualPath') +
                            '/sections/Assignments/edit/' +
                            e.data.Id
                        );
                    }
                }
            });
        },
        getUrlParams: function() {
            const getUrlParams = window
                .location
                .search
                .replace('?', '')
                .split('&')
                .reduce(function(p, e) {
                    let a = e.split('=');
                    p[decodeURIComponent(a[0])] = decodeURIComponent(a[1]);
                    return p;
                }, {}
                );
            const phoneNumber = getUrlParams.phoneNumber;
            return phoneNumber;
        },
        executeExecutorApplicantsQuery: function(phoneNumber) {
            this.config.query.parameterValues = [ {key: '@phone_nunber', value: phoneNumber} ];
            this.loadData(this.afterLoadDataHandler);
        },
        createDGButtons: function(e) {
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
                    icon: 'close',
                    type: 'default',
                    text: 'Опрацьовано',
                    onClick: function(e) {
                        e.event.stopImmediatePropagation();
                        this.openModalCloserForm();
                    }.bind(this)
                },
                location: 'after'
            });
        },
        openModalCloserForm: function() {
            let rows = [];
            const selectedRows = this.dataGridInstance.instance.getSelectedRowsData();
            if(selectedRows.length > 0) {
                selectedRows.forEach(row => rows.push(row.Id));
                const value = rows.join(', ');
                this.messageService.publish({ name: 'openModalForm', id: value });
            }
        },
        createMasterDetail: function(container, options) {
            const currentEmployeeData = options.data;
            const name = 'createMasterDetail';
            const fields = {
                Applicant_Name: 'Заявник',
                ApplicantAdress: 'Адреса заявника',
                Content: 'Зміст'
            };
            this.messageService.publish({
                name, currentEmployeeData, fields, container
            });
        },
        onCellPrepared: function(options) {
            if(options.rowType === 'data') {
                if(options.column.dataField === 'AssignmentState') {
                    const states = options.data.AssignmentState;
                    const spanCircle = this.createElement('div',
                        { classList: 'material-icons', innerText: 'lens', style: 'display: flex; justify-content: center;'}
                    );
                    if(states === 'На перевірці') {
                        spanCircle.classList.add('onCheck');
                    }else if(states === 'Зареєстровано') {
                        spanCircle.classList.add('registrated');
                    }else if(states === 'В роботі') {
                        spanCircle.classList.add('inWork');
                    }else if(states === 'Закрито') {
                        spanCircle.classList.add('closed');
                    }else if(states === 'Не виконано') {
                        spanCircle.classList.add('notDone');
                    }
                    options.cellElement.appendChild(spanCircle);
                }
            }
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
        reloadMainTable: function() {
            this.dataGridInstance.instance.deselectAll();
            this.loadData(this.afterLoadDataHandler);
        },
        afterLoadDataHandler: function() {
            this.render();
        }
    };
}());
