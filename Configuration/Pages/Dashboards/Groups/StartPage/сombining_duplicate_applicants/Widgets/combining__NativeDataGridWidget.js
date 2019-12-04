(function () {
  return {
    config: {
        query: {
            code: 'ak_db_doubles_table2',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'Phone_number',
                caption: 'Номер телефону',
            }, {
                dataField: 'Full_name',
                caption: 'ПІБ',
            }, {
                dataField: 'Address',
                caption: 'Адреса',
            }, {
                dataField: 'Privilege',
                caption: 'Пільга',
            }
        ],
        selection: {
            mode: 'multiple'
        },
        keyExpr: 'Id',
        
        focusedRowEnabled: true,
    },

    init: function() {
        this.loadData(this.afterLoadDataHandler);
        this.sub = this.messageService.subscribe('showApplicants', this.showApplicants, this);
        this.config.onToolbarPreparing = this.createTableButton.bind(this);
    },

    createTableButton: function(e) {
        var toolbarItems = e.toolbarOptions.items;
        toolbarItems.push(
            {
                widget: "dxButton", 
                location: "after",
                options: { 
                    icon: "collapse",
                    type: "default",
                    text: 'Об\'єднати',
                    onClick: function(e) {
                        e.event.stopImmediatePropagation();
                        debugger;
                        const index = this.dataGridInstance.focusedRowKey;
                        const id = this.data[index][0];
                        const phone = this.data[index][1];
                        const rowsId = this.dataGridInstance.selectedRowKeys.join(", ");
                        this.executeQueryCombining(id, phone, rowsId);
                    }.bind(this)
                },
            }, {
                widget: "dxButton", 
                location: "after",
                options: { 
                    icon: "clear",
                    type: "default",
                    text: 'Пропустити',
                    onClick: function(e) {
                        e.event.stopImmediatePropagation();
                        const rowsId = this.dataGridInstance.selectedRowKeys.join(", ");
                        this.executeQueryMissing(rowsId);
                    }.bind(this)
                },
            }
        );
    },

    showApplicants: function (message) {
        this.config.query.parameterValues = [
            { key: '@Id', value: message.id }
        ];
        this.loadData(this.afterLoadDataHandler);
    },

    executeQueryCombining: function (id, rowsId) {
        let query = {
            queryCode: 'ak_db_doubles_ButtonCombine',
            limit: -1,
            parameterValues: [
                { key: '@phone',  value: id},
                { key: '@id1',  value: rowsId},
                { key: '@id1',  value: rowsId},
                { key: '@id1',  value: rowsId}
            ]
        };
        // this.queryExecutor(query, this.response, this);
    },

    executeQueryMissing: function (rowsId) {
        let query = {
            queryCode: 'ak_db_doubles_ButtonSkip',
            limit: -1,
            parameterValues: [
                { key: '@Ids',  value: rowsId}
            ]
        };
        this.queryExecutor(query, this.response, this);
    },

    response: function () {
        this.messageService.publish({ name: 'reloadTable'});
        this.loadData(this.afterLoadDataHandler);
    },

    afterLoadDataHandler: function(data) {
        this.data = data;
        this.render();
    },

    destroy: function(data) {
        this.sub.unsubscribe();
    },
};
}());
