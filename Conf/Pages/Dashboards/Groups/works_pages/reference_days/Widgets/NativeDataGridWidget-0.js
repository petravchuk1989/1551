(function() {
    return {
        config: {
            query: {
                code: 'db_ReferenceEtalonDays',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [
                /*{
                    dataField: 'RatingName',
                    caption: 'Рейтинг',
                    alignment: 'left'
                },*/ {
                    dataField: 'QuestionTypes_Name',
                    caption: 'Тип питання',
                    alignment: 'left'
                }, {
                    dataField: 'EtalonDaysToExecution',
                    caption: 'Еталон виконання',
                    alignment: 'center'
                }, {
                    dataField: 'avg_EtalonDaysToExecution',
                    caption: 'Седернє еталону виконання',
                    alignment: 'center'
                }, {
                    dataField: 'avg_EtalonDaysToExecution_change',
                    caption: 'Новий еталон виконання',
                    alignment: 'center'
                }, {
                    dataField: 'EtalonDaysToExplain',
                    caption: 'Еталон Роз\'яснення',
                    alignment: 'center'
                }, {
                    dataField: 'avg_EtalonDaysToExplain',
                    caption: 'Седернє еталону виконання',
                    alignment: 'center'
                }, {
                    dataField: 'avg_EtalonDaysToExplain_change',
                    caption: 'Новий еталон роз\'яснення',
                    alignment: 'center'
                }, {
                    dataField: 'DateStart',
                    caption: 'Використовується з',
                    dataType: 'date',
                    format: 'dd.MM.yyyy',
                    alignment: 'center'
                },
                {
                    dataField: 'fix_row_icon',
                    caption: '',
                    width:80,
                    allowUpdating:false
                }
            ],
            allowColumnResizing: true,
            columnMinWidth: 50,
            columnAutoWidth: true,
            allowColumnReordering: true,
            pager: {
                showPageSizeSelector: true,
                allowedPageSizes: [50, 100],
                showInfo: true
            },
            paging: {
                pageSize: 100
            },
            export: {
                enabled: true,
                fileName: 'Еталонні дні'
            },
            selection: {
                mode: 'multiple'
            },
            editing: {
                mode: 'cell',
                allowUpdating: true
            },
            columnFixing: {
                enabled: true
            },
            showBorders: true,
            showColumnLines: true,
            showRowLines: true,
            wordWrapEnabled: true,
            keyExpr: 'Id'
        },
        init: function() {
            this.dataGridInstance.height = window.innerHeight - 100;
            this.subscribers.push(this.messageService.subscribe('GlobalFilterChanged', this.setFiltersParams, this));
            this.subscribers.push(this.messageService.subscribe('ApplyGlobalFilters', this.applyGlobalFilters, this));
            this.config.onToolbarPreparing = this.createTableButton.bind(this);

            this.config.onCellPrepared = this.onCellPrepared.bind(this);

            const msg = {
                name: 'SetFilterPanelState',
                package: {
                    value: true
                }
            };
            this.messageService.publish(msg);
        },
        setFiltersParams: function(message) {
            const period = message.package.value.values.find(f => f.name === 'period').value;
            const rating = message.package.value.values.find(f => f.name === 'rating').value.value;
            if(period !== null) {
                if(period.dateFrom !== '' && period.dateTo !== '') {
                    this.dateFrom = this.toUTC(period.dateFrom);
                    this.dateTo = this.toUTC(period.dateTo);
                    this.rating = rating;
                    this.config.query.parameterValues = [
                        {key: '@dateFrom' , value: this.dateFrom },
                        {key: '@dateTo', value: this.dateTo },
                        {key: '@rating' , value: (this.rating ? String(this.rating) : null) }
                    ];
                }
            }
        },
        toUTC(val) {
            let date = new Date(val);
            let year = date.getFullYear();
            let monthFrom = date.getMonth();
            let dayTo = date.getDate();
            let hh = date.getHours();
            let mm = date.getMinutes();
            let dateTo = new Date(year, monthFrom , dayTo, hh + 3, mm)
            return dateTo
        },
        onCellPrepared: function(options) {
            if(options.rowType === 'data') {
                if(options.column.dataField === 'fix_row_icon') {
                    const icon = this.createElement('span',{className:'material-icons create fix-row ',textContent:'create'})
                    icon.addEventListener('click',()=>{
                        this.openModal()
                    })
                    const arrClasses = ['cell-icon','dx-command-select','dx-editor-cell','dx-editor-inline-block','dx-cell-focus-disabled']
                    arrClasses.forEach(elem=>options.cellElement.classList.add(elem))
                    options.cellElement.append(icon);
                }
            }
        },
        openModal() {
            const rowId = this.dataGridInstance.selectedRowKeys;
            if(rowId.length >= 1) {
                const mainWidget = document.querySelector('.root-main')
                const int = mainWidget.querySelector('.lookup-con')
                const int2 = mainWidget.querySelector('.blocker')
                if(int) {
                    int.remove()
                }
                if(int2) {
                    int2.remove()
                }
                const blocker = this.createElement('div',{className:'blocker',id:'blocker'})
                blocker.addEventListener('click',this.removeLookup.bind(this))
                const con = this.createElement('div',{className:'lookup-con',id:'lookup-con'})
                const buttonsCon = this.createElement('div',{className:'lookup-buttons-con'})
                const buttonAdd = this.createElement('button',{className:'btn add-btn',textContent:'Застосувати'})
                buttonAdd.addEventListener('click',this.sendDate.bind(this,rowId))
                const buttonExit = this.createElement('button',{className:'btn exit-btn',textContent:'Вийти'})
                buttonExit.addEventListener('click',this.removeLookup.bind(this))
                const convertDate = new Date(this.dateTo).toISOString().slice(0,10)
                const dataInput = this.createElement('input',{className:'date-input',
                    id:'date-input',type:'date',value:convertDate,min:convertDate})
                buttonsCon.append(buttonAdd,buttonExit)
                con.append(buttonsCon,dataInput)
                mainWidget.append(blocker,con)
            }
        },
        sendDate() {
            const int = this.dataGridInstance.instance.getSelectedRowsData()
            const dateVal = document.getElementById('date-input').value;
            int.forEach(elem=>{
                elem.DateStart = dateVal;
            })
            this.removeLookup();
        },
        updateGrid() {
            this.removeLookup();
        },
        removeLookup() {
            const blocker = document.getElementById('blocker')
            const con = document.getElementById('lookup-con')
            blocker.remove()
            con.remove()
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
        createTableButton: function(e) {
            let toolbarItems = e.toolbarOptions.items;
            toolbarItems.push({
                widget: 'dxButton',
                options: {
                    icon: 'check',
                    type: 'default',
                    text: 'Застосувати',
                    onClick: () => {
                        this.applyRowsChanges();
                    }
                },
                location: 'after'
            });
        },
        applyRowsChanges: function() {
            const rows = this.dataGridInstance.instance.getSelectedRowsData();
            if(rows.length) {
                this.showPagePreloader('Зачекайте, дані обробляються');
                this.promiseAll = [];
                rows.forEach(row => {
                    const promise = new Promise((resolve) => {
                        row.avg_EtalonDaysToExecution_change = (row.avg_EtalonDaysToExecution_change == 0 ? 1 : row.avg_EtalonDaysToExecution_change)
                        row.avg_EtalonDaysToExplain_change = (row.avg_EtalonDaysToExplain_change == 0 ? 1 : row.avg_EtalonDaysToExplain_change)

                        const executeApplyRowsChanges = this.createExecuteApplyRowsChanges(row);
                        this.queryExecutor(executeApplyRowsChanges, this.applyRequest.bind(this, resolve), this);
                        this.showPreloader = false;
                    });
                    this.promiseAll.push(promise);
                    this.afterApplyAllRequests();
                });                
            }
        },
        createExecuteApplyRowsChanges: function(row) {
            return {
                queryCode: 'db_ReferenceEtalonDays_apply',
                limit: -1,
                parameterValues: [
                    { key: '@QuestionTypes_Id', value: row.QuestionTypes_Id },
                    { key: '@DateStart', value: new Date(row.DateStart) },
                    { key: '@avg_EtalonDaysToExplain_change', value: row.avg_EtalonDaysToExplain_change },
                    { key: '@avg_EtalonDaysToExecution_change', value: row.avg_EtalonDaysToExecution_change }
                ]
            };
        },
        applyRequest: function(resolve, data) {
            resolve(data);
        },
        afterApplyAllRequests: function() {
            debugger
            Promise.all(this.promiseAll).then(() => {
                this.promiseAll = [];
                this.dataGridInstance.instance.deselectAll();
                this.afterLoadDataHandler();
                this.hidePagePreloader();
            });
        },
        applyGlobalFilters: function() {
            if (this.rating != undefined && this.rating != null) {
                const msg = {
                    name: 'SetFilterPanelState',
                    package: {
                        value: false
                    }
                };
                this.messageService.publish(msg);
                this.loadData(this.afterLoadDataHandler);
            }
            
        },
        afterLoadDataHandler: function() {
            this.render();
        }
    };
}());
