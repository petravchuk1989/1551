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

                dataField: 'executor_role_level_id',
                caption: 'Кількість дзвінків',
            }
        ],
        keyExpr: 'priority',
    },

    init: function() {
        this.sub = this.messageService.subscribe('reloadTable', this.reloadTable, this);
        this.loadData(this.afterLoadDataHandler);

        this.dataGridInstance.onCellClick.subscribe(e => {
            if(e.column) {
                const dataField = this.config.columns[0].dataField;
                if(e.column.dataField == dataField && e.row != undefined){
                    this.messageService.publish({ name: 'showApplicants', id: e.data.Id});
                }
            }
        });
    },

    reloadTable: function () {
        this.loadData(this.afterLoadDataHandler);
    },

    afterLoadDataHandler: function(data) {
        this.render();
    },

    destroy: function(data) {
        this.sub.unsubscribe();
    },
};
}());
