(function() {
    return {
        config: {
            query: {
                code: 'ak_Fil_ConOrgGroups',
                parameterValues: [],
                filterColumns: [],
                sortColumns: [],
                skipNotVisibleColumns: true,
                chunkSize: 1000
            },
            columns: [
                {
                    dataField: 'Name',
                    caption: 'Групи питань'
                }
            ],
            selection: {
                mode: 'single'
            },
            filterRow: {
                visible: true
            },
            keyExpr: 'Id'
        },
        init: function() {
            this.dataGridInstance.height = String(window.innerHeight - 200);
            document.getElementById('NativeDataGridWidget-1').style.display = 'none';
            document.getElementById('NativeDataGridWidget-0').style.display = 'none';
            this.sub = this.messageService.subscribe('showTable', this.showTable, this);
            this.config.onToolbarPreparing = this.createTableButton.bind(this);
            this.loadData(this.afterLoadDataHandler);
        },
        createTableButton: function(e) {
            let toolbarItems = e.toolbarOptions.items;
            toolbarItems.push({
                widget: 'dxButton',
                location: 'after',
                options: {
                    icon: 'add',
                    type: 'default',
                    onClick: function(e) {
                        e.event.stopImmediatePropagation();
                        this.sendSelectItem();
                    }.bind(this)
                }
            });
        },
        sendSelectItem: function() {
            let selectedRow = this.dataGridInstance.instance.getSelectedRowsData();
            this.messageService.publish({ name: 'sendSelectedRow', value: selectedRow, position: 'groups' });
        },
        showTable: function(message) {
            if(message.value === 'group') {
                document.getElementById('question_groups').style.display = 'block';
                document.getElementById('NativeDataGridWidget-0').style.display = 'block';
                document.getElementById('NativeDataGridWidget-1').style.display = 'block';
                document.getElementById('widgetFiltersInfo').style.display = 'none';
            }else if(message.value === 'default') {
                document.getElementById('question_groups').style.display = 'none';
                document.getElementById('NativeDataGridWidget-0').style.display = 'block';
                document.getElementById('NativeDataGridWidget-1').style.display = 'block';
                document.getElementById('widgetFiltersInfo').style.display = 'none';
            }else if(message.value === 'filter') {
                document.getElementById('question_groups').style.display = 'none';
                document.getElementById('NativeDataGridWidget-0').style.display = 'none';
                document.getElementById('NativeDataGridWidget-1').style.display = 'none';
                document.getElementById('widgetFiltersInfo').style.display = 'block';
            }
        },
        afterLoadDataHandler: function() {
            this.render();
        },
        destroy: function() {
            this.sub.unsubscribe();
        }
    };
}());
