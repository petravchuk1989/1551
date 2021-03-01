(function() {
    return {
        config: {
            query: {
                code: 'Polls_SelectRows',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            paging: {
                pageSize: 10
            },
            pager: {
                showPageSizeSelector: true,
                allowedPageSizes: [10, 25, 50, 100]
            },
            editing: {
                useIcons: true
            },
            focusedRowEnabled: false,
            remoteOperations: false,
            allowColumnReordering: true,
            allowColumnResizing: true,
            wordWrapEnabled: true,
            rowAlternationEnabled: true,
            hoverStateEnabled: true,
            filterRow: { visible: true },
            keyExpr: '',
            showBorders: true,
            columns: [
                {
                    dataField: 'poll_name',
                    caption: 'Опитування',
                    width:500
                },
                {
                    dataField: 'idIcon',
                    caption: '',
                    width:80
                },
                {
                    dataField: 'start_date',
                    caption: 'Дата старту',
                    width:100
                },
                {
                    dataField: 'end_date',
                    caption: 'Дата завершення',
                    width:100
                },
                {
                    dataField: 'name',
                    caption: 'Напрямок',
                    width:300
                },
                {
                    dataField: 'col_Applicants',
                    caption: 'Людей для опитування'
                },
                {
                    dataField: 'col_IsPollsApplicants',
                    caption: 'Опитано'
                },
                {
                    dataField: 'col_IsNotApplicants',
                    caption: 'Відмовились'
                },
                {
                    dataField: 'fix_row_icon',
                    caption: '',
                    width:80
                }
            ]
        },
        init: function() {
            this.subscribers.push(this.messageService.subscribe('GlobalFilterChanged', this.getFiltersParams, this));
            this.sendQuery = true;
            this.subscribers.push(this.messageService.subscribe('ApplyGlobalFilters', this.applyCallBack, this));
            this.subscribers.push(this.messageService.subscribe('updateDataGrid', this.updateDataGrid, this));
            this.config.onCellPrepared = this.onCellPrepared.bind(this);
        },
        getFiltersParams: function(message) {
            this.config.query.filterColumns = [];
            const period = message.package.value.values.find(f => f.name === 'period').value;
            const activity = message.package.value.values.find(f => f.name === 'Activity').value;
            const direction = message.package.value.values.find(f => f.name === 'Direction').value;
            this.activity = activity === '' ? null : activity.value;
            if(period !== null) {
                if(period.dateFrom !== '' && period.dateTo !== '') {
                    this.dateFrom = period.dateFrom;
                    this.dateTo = period.dateTo;
                    this.direction = this.extractOrgValues(direction);
                    if (this.direction.length > 0) {
                        let filter = {
                            key: 'PollDirId',
                            value: {
                                operation: 0,
                                not: false,
                                values: this.direction
                            }
                        };
                        this.config.query.filterColumns.push(filter);
                    }
                    if(this.sendQuery) {
                        this.sendQuery = false;
                        this.applyCallBack();
                    }
                }
            }
        },
        updateDataGrid() {
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
        extractOrgValues: function(items) {
            if(items.length && items !== '') {
                const valuesList = [];
                items.forEach(item => valuesList.push(item.value));
                return valuesList;
            }
            return [];
        },
        onCellPrepared: function(options) {
            const arr = ['event','event','keyboard_arrow_down','keyboard_arrow_right','code']
            if(options.rowType === 'data') {
                if(options.column.dataField === 'idIcon') {
                    const index = options.cellElement.textContent - 1;
                    options.cellElement.classList.add('cell-icon');
                    const classRed = index === 0 ? ' green' : '';
                    const classGreen = index === 1 ? ' red' : '';
                    options.cellElement.textContent = '';
                    const icon = `<span class="material-icons ${classRed} ${classGreen}"> ${arr[index]} </span>`;
                    options.cellElement.insertAdjacentHTML('afterbegin',icon);
                }else if(options.column.dataField === 'fix_row_icon') {
                    options.cellElement.classList.add('cell-icon');
                    const icon = this.createElement('span',{className:'material-icons create fix-row',textContent:'create'})
                    icon.addEventListener('click',()=>{
                        const insertRowQuery = {
                            queryCode: 'PollQuestionAnswers_SelectRows',
                            limit: -1,
                            parameterValues: [
                                {key: '@poll_id', value: options.data.Polls_Id}
                            ]
                        };
                        this.queryExecutor(insertRowQuery,this.openFormCon.bind(this,options),this);
                    })
                    options.cellElement.append(icon);
                }
            }
        },
        openFormCon(options,response) {
            const {PollDirId,end_date,is_active,poll_name,start_date,Polls_Id,people_limit} = options.data;
            const obj = {
                dateFrom:start_date,
                dateTo:end_date,
                name:poll_name,
                direction:PollDirId,
                rowId:Polls_Id,
                activity:is_active,
                applicants:people_limit
            }
            const fixRow = true;
            if(response.rows[0].values[0]) {
                obj.variants = JSON.parse(response.rows[0].values);
            }
            this.setVisibility(fixRow,obj)
        },
        applyCallBack() {
            this.hideFilterPanel();
            this.config.query.parameterValues = [
                {key: '@DateStart' , value: this.dateFrom },
                {key: '@DateEnd', value: this.dateTo },
                {key: '@is_active', value: this.activity }
            ];
            this.loadData(this.afterLoadDataHandler);
            this.createSetVisibility();
        },
        hideFilterPanel() {
            const msg = {
                name: 'SetFilterPanelState',
                package: {
                    value: false
                }
            };
            this.messageService.publish(msg);
        },
        createSetVisibility() {
            const con = document.getElementById('NativeDataGridWidget-0')
            let addTaskDiv = document.getElementById('add-task-block');
            if(addTaskDiv) {
                addTaskDiv.remove()
            }
            const div = this.createElement('div',{classList:'add-task-block',id: 'add-task-block'});
            const btn = this.createElement('button',{classList:'add-task',textContent: 'Додати'});
            btn.addEventListener('click', this.setVisibility.bind(this))
            div.insertAdjacentElement('beforeend',btn)
            con.insertAdjacentElement('beforebegin',div)
        },
        setVisibility(fixRow,options = '') {
            const mainCon = document.getElementById('first_widget')
            const tab = document.getElementById('second_widget')
            const msg = {
                name: 'setVisibilityNone',
                package: {
                    display: 'none',
                    container: mainCon
                }
            };
            const msg2 = {
                name: 'setVisibilityBlock',
                package: {
                    display: 'block',
                    container: tab,
                    fixRow,
                    options
                }
            }
            this.messageService.publish(msg);
            this.messageService.publish(msg2);
        },
        afterLoadDataHandler: function() {
            this.render();
        }
    };
}());
