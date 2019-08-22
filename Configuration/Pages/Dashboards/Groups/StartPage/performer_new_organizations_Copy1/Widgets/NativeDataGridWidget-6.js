(function () {
  return {
    config: {
        query: {
            code: 'NaDooprNemaMozhlVyk',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'registration_number',
                caption: 'Номер питання',
                width: 150
            }, {
                dataField: 'QuestionType',
                caption: 'Тип питання',
            }, {
                dataField: 'zayavnyk',
                caption: 'Заявник',
            }, {
                dataField: 'adress',
                caption: 'Місце проблеми',
            }, {
                dataField: 'control_date',
                caption: 'Дата контролю',
                dataType: "datetime",
                format: "dd.MM.yyyy HH:mm"              
            }
        ],
        export: {
            enabled: true,
            fileName: 'Excel'
        },
        searchPanel: {
            visible: false,
            highlightCaseSensitive: true
        },
        masterDetail: {
            enabled: true,
        },
        pager: {
            showPageSizeSelector: false,
            allowedPageSizes: [10, 15, 30],
            showInfo: false,
            pageSize: 10
        },
        editing: {
            enabled: false,
            allowAdding: false,
        },
        scrolling: {
            mode: 'standart',
            rowRenderingMode: null,
            columnRenderingMode: null,
            showScrollbar: null
        },
        selection: {
            mode: "multiple"
        },
        sorting: {
            mode: "multiple"
        },
        filterRow: {
            visible: true,
            applyFilter: "auto"
        }, 
        keyExpr: 'Id',
        showBorders: false,
        showColumnLines: false,
        showRowLines: true,
        remoteOperations: null,
        allowColumnReordering: null,
        allowFiltering: false,
        rowAlternationEnabled: null,
        columnAutoWidth: null,
        hoverStateEnabled: true,
        columnWidth: null,
        wordWrapEnabled: true,
        allowColumnResizing: true,
        showFilterRow: true,
        showHeaderFilter: false,
        showColumnChooser: false,
        showColumnFixing: true,
        groupingAutoExpandAll: null,
        onRowUpdating: function(data) {},
        onRowExpanding: function(data) {},
        onRowInserting: function(data) {},
        onRowRemoving: function(data) {},
        onCellClick: function(data) {},
        onRowClick: function(data) {},
        selectionChanged: function(data) {}
    },
    sub: [],
    containerForChackedBox: [],
    init: function() {
        document.getElementById('table10_Plan_Programs').style.display = 'none';
        this.sub = this.messageService.subscribe('clickOnTable2', this.changeOnTable, this);
        this.config.masterDetail.template = this.createMasterDetail.bind(this);
        this.dataGridInstance.onCellClick.subscribe(e => {
            if(e.column.dataField == "registration_number" && e.row != undefined){
                window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/Assignments/edit/"+e.key+"");
            }
        });
    },
    changeOnTable: function(message){
        if( message.column != 'План/Програма'){
            document.getElementById('table10_Plan_Programs').style.display = 'none';
        }else{
            document.getElementById('table10_Plan_Programs').style.display = 'block';
            this.config.query.queryCode = 'NaDooprNemaMozhlVyk';
            this.config.query.parameterValues = [{ key: '@organization_id',  value: message.orgId},
                                                 { key: '@column', value: message.column},
                                                 { key: '@navigation', value: message.navigation}];
            this.loadData(this.afterLoadDataHandler);          
        }
    },
    
    createMasterDetail: function(container, options) {
        var currentEmployeeData = options.data;
        
        if(currentEmployeeData.short_answer == null || currentEmployeeData.short_answer == undefined){
            currentEmployeeData.short_answer = '';
        }
        if(currentEmployeeData.zayavnyk_zmist == null || currentEmployeeData.zayavnyk_zmist == undefined){
            currentEmployeeData.zayavnyk_zmist = '';
        }
        if(currentEmployeeData.zayavnyk_adress == null || currentEmployeeData.zayavnyk_adress == undefined){
            currentEmployeeData.zayavnyk_adress = '';
        }
        if(currentEmployeeData.balans_name == null || currentEmployeeData.balans_name == undefined){
            currentEmployeeData.balans_name = '';
        }
        let elementAdress__content = this.createElement('div', { className: 'elementAdress__content content', innerText: ""+currentEmployeeData.zayavnyk_adress+""});
        let elementAdress__caption = this.createElement('div', { className: 'elementAdress__caption caption', innerText: "Адреса заявника"});
        let elementAdress = this.createElement('div', { className: 'elementAdress element'}, elementAdress__caption, elementAdress__content);
        
        let elementСontent__content = this.createElement('div', { className: 'elementСontent__content content', innerText: ""+currentEmployeeData.zayavnyk_zmist+""});
        let elementСontent__caption = this.createElement('div', { className: 'elementСontent__caption caption', innerText: "Зміст"});
        let elementСontent = this.createElement('div', { className: 'elementСontent element'}, elementСontent__caption, elementСontent__content);
        
        let elementComment__content = this.createElement('div', { className: 'elementComment__content content', innerText: ""+currentEmployeeData.short_answer+""});
        let elementComment__caption = this.createElement('div', { className: 'elementComment__caption caption', innerText: "Коментар виконавця"});
        let elementComment = this.createElement('div', { className: 'elementСontent element'}, elementComment__caption, elementComment__content);
        
        let elementBalance__content = this.createElement('div', { className: 'elementBalance__content content', innerText: ""+currentEmployeeData.balans_name+""});
        let elementBalance__caption = this.createElement('div', { className: 'elementBalance__caption caption', innerText: "Балансоутримувач"});
        let elementBalance = this.createElement('div', { className: 'elementСontent element'}, elementBalance__caption, elementBalance__content); 
        
        let elementsWrapper  = this.createElement('div', { className: 'elementsWrapper'}, elementAdress, elementСontent, elementComment, elementBalance);
        container.appendChild(elementsWrapper);
        
        let elementsAll = document.querySelectorAll('.element');
        elementsAll.forEach( el => {
            el.style.display = 'flex';
            el.style.margin = '15px 10px';
        })
        let elementsCaptionAll = document.querySelectorAll('.caption');
        elementsCaptionAll.forEach( el => {
            el.style.minWidth = '200px';
        })
    },     
	afterLoadDataHandler: function(data) {
		this.render();
		this.createCustomStyle();
	},
    createCustomStyle: function(){
        let elements = document.querySelectorAll('.dx-datagrid-export-button');
        elements.forEach( function(element){
            let spanElement = this.createElement('span', { className: 'dx-button-text', innerText: 'Excel'});
            element.firstElementChild.appendChild(spanElement);
        }.bind(this));
    }, 
    destroy: function() {
        this.sub.unsubscribe();
    }
};
}());
