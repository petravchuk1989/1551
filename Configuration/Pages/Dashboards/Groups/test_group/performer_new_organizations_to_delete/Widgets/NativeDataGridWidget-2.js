(function () {
  return {
    config: {
        query: {
            code: 'NeVKompetentcii',
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
            },  {
                dataField: 'QuestionType',
                caption: 'Тип питання',
                sortOrder: 'asc',
                allowSorting: true,
            },  {
                dataField: 'zayavnyk',
                caption: 'Заявник',
            },  {
                dataField: 'adress_place',
                caption: 'Місце проблеми',
            },  {
                dataField: 'pidlegliy',
                caption: 'Виконавець',
            },  {
                dataField: 'transfer_to_organization_id',
                caption: 'Можливий виконавець',
                lookup: {
                    dataSource: {
                        paginate: true,
                        store: this.elements,
                    },
                    valueExpr: "ID",
                    displayExpr: "Name"
                }
            }
        ],
        masterDetail: {
            enabled: true,
        },
        filterRow: {
            visible: true,
            applyFilter: "auto"
        },
        export: {
            enabled: true,
            fileName: 'Excel'
        },
        searchPanel: {
            visible: false,
            highlightCaseSensitive: true
        },
        pager: {
            showPageSizeSelector: false,
            allowedPageSizes: [10, 15, 30],
            showInfo: false,
            pageSize: 10
        },
        editing: {
            mode: 'row',
            allowUpdating: true,
            useIcons: true
        },
        scrolling: {
            mode: 'standart',
            rowRenderingMode: null,
            columnRenderingMode: null,
            showScrollbar: null
        },
        sorting: {
            mode: "multiple"
        },
        keyExpr: 'Id',
        showBorders: false,
        showColumnLines: false,
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
        showHeaderFilter: false,
        showColumnChooser: false,
        showColumnFixing: true,
        groupingAutoExpandAll: null,
    },
    childs: [],
    OrganizationId: [],
    elements: [],
    init: function() {
        this.changedRows = [];
        document.getElementById('table5__NeVKompetentcii').style.display = 'none';
        this.sub = this.messageService.subscribe('clickOnTable2', this.changeOnTable, this);
        this.sub1 = this.messageService.subscribe('messageWithOrganizationId', this.takeOrganizationId, this);
        
        this.config.masterDetail.template = this.createMasterDetail.bind(this);
        this.dataGridInstance.onCellClick.subscribe(e => {
            if(e.column.dataField == "registration_number" && e.row != undefined){
                window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/Assignments/edit/"+e.key+"");
            }
        });
        this.config.onToolbarPreparing = this.createTableButton.bind(this);
        this.dataGridInstance.onRowUpdating.subscribe( e => {
            if( this.changedRows.length > 0){
                let data = this.changedRows;
                for ( let  i = 0; i < data.length; i ++){
                    let item = data[i];
                    if( item.id == e.key){
                        this.changedRows.splice(i,1);
                        break
                    }
                }
                var element = {
                    id: e.key,
                    newId: e.newData.transfer_to_organization_id
                }
            }else{
                var element = {
                    id: e.key,
                    newId: e.newData.transfer_to_organization_id
                }
            }
            this.changedRows.push(element);
        });        
    },
    changeOnTable: function(message){
        this.column = message.column;
        this.navigator = message.navigation;
        this.targetId = message.targetId;
        if(message.column != 'Не в компетенції'){
            document.getElementById('table5__NeVKompetentcii').style.display = 'none';
        }else{
            document.getElementById('table5__NeVKompetentcii').style.display = 'block';
            this.config.query.queryCode = 'NeVKompetentsii';
            this.config.query.parameterValues = [{ key: '@organization_id',  value: message.orgId},
                                                 { key: '@organizationName', value: message.orgName},
                                                 { key: '@navigation', value: message.navigation}];
            this.loadData(this.afterLoadDataHandler);
            
            let executeQuery = {
                queryCode: 'Lookup_NeVKompetencii_PidOrganization',
                parameterValues: [  {key: '@organization_id', value: this.OrganizationId} ],
                limit: -1
            };
            this.queryExecutor(executeQuery, this.lookupFoo, this);
        }
    },
    findAllRowsNeVKompetentсii: function(message){
        let elements = this.changedRows;
        elements.map( el => {
            let executeQuery = {
                queryCode: 'Button_NeVKompetentcii',
                parameterValues: [ {key: '@executor_organization_id', value: el.newId},
                                   {key: '@Id', value: el.id}  ],
                limit: -1
            };        
            this.queryExecutor(executeQuery);
        });
        this.changedRows = [];
        this.loadData(this.afterLoadDataHandler);
        
        this.messageService.publish( { name: 'reloadMainTable', column: this.column,   navigator: this.navigator, targetId: this.targetId });
    },    
    createTableButton: function(e) {
        var toolbarItems = e.toolbarOptions.items;

        toolbarItems.push({
            widget: "dxButton", 
            options: { 
                icon: "upload",
                type: "default",
                text: "Передати",
                onClick: function(e) { 
                     this.findAllRowsNeVKompetentсii();
                }.bind(this)
            },
            location: "after"
        });
    },
    createElement: function(tag, props, ...children) {
        const element = document.createElement(tag);
        Object.keys(props).forEach( key => element[key] = props[key] );
        if(children.length > 0){
            children.forEach( child =>{
                element.appendChild(child);
            });
        } return element;
    },    
    lookupFoo: function(data) {
        this.elements = [];
        for( i = 0; i < data.rows.length; i++){
            let el = data.rows[i];
            let obj = {
                "ID": el.values[0],
                "Name": el.values[1],
            } 
            this.elements.push(obj);
        }
        this.config.columns[5].lookup.dataSource.store = this.elements;
        this.loadData(this.afterLoadDataHandler);
    },
    afterLoadDataHandler: function(){
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
    createMasterDetail: function(container, options) {
        var currentEmployeeData = options.data;
        
        if(currentEmployeeData.comment == null || currentEmployeeData.comment == undefined){
            currentEmployeeData.comment = '';
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
        
        let elementComment__content = this.createElement('div', { className: 'elementComment__content content', innerText: ""+currentEmployeeData.comment+""});
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
        });
        let elementsCaptionAll = document.querySelectorAll('.caption');
        elementsCaptionAll.forEach( el => {
            el.style.minWidth = '200px';
        });
    },
    takeOrganizationId: function(message){
        this.OrganizationId = message.value;
    },
    destroy: function() {
        this.sub.unsubscribe();
        this.sub1.unsubscribe();
    }
};
}());
