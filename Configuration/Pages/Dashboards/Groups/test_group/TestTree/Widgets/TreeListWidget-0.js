(function () {
  return {
    config: {
        query: {
            code: 'ys_List_QuestionTypes2_SelectRows',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        keyExpr: 'Id',
        parentIdExpr: 'ParentId',
        expandedRowKeys: [1],
        selectedRowKeys: [1],
        columnAutoWidth: true,
        wordWrapEnabled: true,
        showRowLines: true,
        allowColumnReordering: true,
        allowColumnResizing: true,
        columnMinWidth: '50',
        showBorders: true,
        filterValue: null,
        columns: [
            {
                dataField: 'Name',
                caption: 'Name'
            }
        ],
        columnFixing: {
            enabled: true
        },
        searchPanel: {
            visible: true,
            width: null
        },
        headerFilter: {
            visible: true
        },
        filterRow: {
            visible: true
        },
        filterPanel: {
            visible: false
        },
        selection: {
            mode: "single"
        },
        columnChooser: {
            enabled: true,
            allowSearch: 'allowSearch'
        },
        paging: {
            enabled: false,
            pageSize: null
        },
        pager: {
            showPageSizeSelector: false,
            allowedPageSizes: [],
            showInfo: false
        },
        onSelectionChanged: function(e) {
            debugger;
        }
    },
    init: function() {
        this.loadData();
    }
};
}());
