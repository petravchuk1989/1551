(function () {
  return {
    config: {
        query: {
            code: 'test',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'priority',
                caption: 'Номер телефону',
            }, {
                dataField: 'main',
                caption: 'Кількість дзвінків',
            }, {
                dataField: 'executor_role_level_id',
                caption: 'Кількість дзвінків',
            }, {
                dataField: 'priocessing_kind_id',
                caption: 'Кількість дзвінків',
            }
        ],
        selection: {
            mode: 'multiple'
        },
        keyExpr: 'priority',
        
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
                        const index = this.dataGridInstance.focusedRowKey;
                        const id = this.data[index][0];
                        const rowsId = this.dataGridInstance.selectedRowKeys.join(", ");
                        this.executeQueryCombining(id, rowsId);
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
        // this.config.query.parameterValues = [
        //     { key: '@id', value: message.id }
        // ];
        this.loadData(this.afterLoadDataHandler);
    },

    executeQueryCombining: function (id, rowsId) {
        let query = {
            queryCode: this.config.query.code,
            limit: -1,
            parameterValues: [
                { key: '@id',  value: id},
                { key: '@id1',  value: rowsId}
            ]
        };
        this.queryExecutor(query, this.response, this);
    },

    executeQueryMissing: function (rowsId) {
        let query = {
            queryCode: this.config.query.code,
            limit: -1,
            parameterValues: [
                { key: '@id',  value: rowsId}
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
