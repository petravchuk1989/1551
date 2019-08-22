(function () {
  return {
    config: {
        query: {
            code: 'CoordinatorController_NeVKompetentsii',
            parameterValues: [ {key: "@navigation", value: "УГЛ"} ],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'registration_number',
                caption: 'Номер питання',
                dataType: null,
                format: null,
                width: null,
                alignment: null,
                groupIndex: null,
                fixed: true,
                allowSorting: true,
                subColumns: []
            }, {
                dataField: 'QuestionType',
                caption: 'Тип питання',
                dataType: null,
                format: null,
                width: null,
                alignment: null,
                groupIndex: null,
                fixed: true,
                allowSorting: true,
                subColumns: []
            }, {
                dataField: 'zayavnikName',
                caption: 'Заявник',
                dataType: null,
                format: null,
                width: null,
                alignment: null,
                groupIndex: null,
                fixed: true,
                allowSorting: true,
                subColumns: []
            }, {
                dataField: 'adress',
                caption: 'Місце проблеми',
                dataType: null,
                format: null,
                width: null,
                alignment: null,
                groupIndex: null,
                fixed: true,
                allowSorting: true,
                subColumns: []
            }, {
                dataField: 'vykonavets',
                caption: 'Виконавець',
                dataType: null,
                format: null,
                width: null,
                alignment: null,
                groupIndex: null,
                fixed: true,
                sortOrder: 'asc',
                allowSorting: true,
                subColumns: []
            }, 
            
            {
                dataField: 'Id',
                caption: 'Можливий виконавець',
                dataType: null,
                lookup: {
                    dataSource: {
                        store: this.states,
                    },
                    valueExpr: "ID",
                    displayExpr: "Name"
                }
            }
        ],
        searchPanel: {
            visible: true,
            highlightCaseSensitive: false
        },
        pager: {
            showPageSizeSelector:  false,
            allowedPageSizes: [10, 15, 30],
            showInfo: true,
            pageSize: 10
        },
        export: {
            enabled: false,
            fileName: 'File_name'
        },
        editing: {
            mode: 'batch',
            allowUpdating: true,
            useIcons: true
        },
        filterRow: {
            visible: true,
            applyFilter: "auto"
        },
        height: '550',
        keyExpr: 'Id',
        showBorders: true,
        showColumnLines: true,
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
        showHeaderFilter: true,
        showColumnChooser: true,
        showColumnFixing: true,
        groupingAutoExpandAll: null,
        selectionMode: 'multiple',
    },
    sub: [],
    sub1: [],
    states: [],
    elements: [],
    init: function() {

    this.dataGridInstance.onCellPrepared.subscribe  ( e => {
        // console.log('onCellPrepared')
    });  
    this.dataGridInstance.accessKeyChange.subscribe  ( e => {
        console.log('access Key Change')
    });  
    // this.dataGridInstance.onSelectionChanged.subscribe  ( e => {
    //     console.log('onSelectionChanged')
    // });  
    // this.dataGridInstance.onFocusedRowChanging.subscribe  ( e => {
    //     console.log('onFocusedRowChanging')
    // });    
    this.dataGridInstance.onOptionChanged.subscribe ( e => {
        // console.log('onOptionChanged')
    });    
    this.dataGridInstance.onRowUpdated.subscribe ( e => {
        console.log('after update all rows')
    });    
        
        
    this.dataGridInstance.onEditingStart.subscribe ( e => {
        // console.log(e)
        console.log('editing start')
    });
        
    // debugger;    
        
    var that = this;    
    this.dataGridInstance.onRowUpdating.subscribe( function(e, that ) {
        console.log('onRowUpdating');
        console.log(e.component.getDataSource().store());
        
        var oldId = e.oldData;
        var newId = e.newData.Id;
        var eKey = e.key;
        // e.component.getDataSource().store().update(oldId, {Id: newId});

        e.component.getDataSource().store().update(eKey, {Id: 123});
        e.component.getDataSource().store().update(e, {eKey: 1233434});
        // e.key = e.newData.Id
        // e.oldData = e.key
        debugger;
        let executeQuery = {
            queryCode: 'query_for_send_e.Id',
            limit: -1,
            parameterValues: [  ]
        };
        
    });

        this.config.query.queryCode = 'CoordinatorController_NeVKompetentsii';
        this.config.query.parameterValues = [ {key: "@navigation", value: "УГЛ"} ];
        this.loadData(this.afterLoadDataHandler);
        
    },
    afterLoadDataHandler: function(data) {
        
        this.elements = [];
        for( i = 0; i < data.length; i++){
            let el = data[i];
            let obj = {
                "ID": el[0],
                "Name": el[5],
            } 
            this.elements.push(obj);
        }
        this.config.columns[5].lookup.dataSource.store = this.elements;
        console.log( this.elements);
        this.render();
    },
};
}());
