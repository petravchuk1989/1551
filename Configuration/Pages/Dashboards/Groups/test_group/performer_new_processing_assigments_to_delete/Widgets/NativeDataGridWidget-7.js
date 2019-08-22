(function () {
  return {
    config: {
        query: {
            code: 'Poshuk',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'id',
                caption: '',
                width: '0',
                fixed: true,

            }, {
                dataField: 'navigation',
                caption: 'Джерело надходження',
                fixed: true,
            }, {
                dataField: 'registration_number',
                caption: 'Номер питання',
                fixed: true,
                sortOrder: 'asc',
                width: 150
            }, {
                dataField: 'QuestionType',
                caption: 'Тип питання',
                fixed: true,
            }, {
                dataField: 'zayavnyk',
                caption: 'Заявник',
                fixed: true,
            }, {
                dataField: 'adress',
                caption: 'Місце проблеми',
                fixed: true,
            }, {
                dataField: 'vykonavets',
                caption: 'Виконавець',
                fixed: true,
            }
        ],
        filterRow: {
            visible: true,
            applyFilter: "auto"
        },
        masterDetail: {
            enabled: true,
        },        
        searchPanel: {
            visible: false,
            highlightCaseSensitive: true
        },
		pager: {
            showPageSizeSelector:  true,
            allowedPageSizes: [10, 15, 30],
            showInfo: true,
            pageSize: 10
        },
        paging: {
            pageSize: 10
        },  
        editing: {
            enabled: false,
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
    sub: [],
    sub1: [],
    init: function() {
        document.getElementById('searchTable').style.display = 'none';
        this.sub = this.messageService.subscribe('resultSearch', this.changeOnTable, this);
        this.sub1 = this.messageService.subscribe('clearInput', this.hideAllTable, this);
        this.sub2 = this.messageService.subscribe('clickOnСoordinator_table', this.hideSearchTable, this);
        
        this.config.masterDetail.template = this.createMasterDetail.bind(this);
    },
    createMasterDetail: function(container, options) {        
        var currentEmployeeData = options.data;

        if(currentEmployeeData.short_answer == null || currentEmployeeData.short_answer == undefined){
            currentEmployeeData.short_answer = '';
        }
        if(currentEmployeeData.question_content == null || currentEmployeeData.question_content == undefined){
            currentEmployeeData.question_content = '';
        }
        if(currentEmployeeData.adressZ == null || currentEmployeeData.adressZ == undefined){
            currentEmployeeData.adressZ = '';
        }
        if(currentEmployeeData.balans_name == null || currentEmployeeData.balans_name == undefined){
            currentEmployeeData.balans_name = '';
        }
        let elementAdress__content = this.createElement('div', { className: 'elementAdress__content content', innerText: ""+currentEmployeeData.adressZ+""});
        let elementAdress__caption = this.createElement('div', { className: 'elementAdress__caption caption', innerText: "Адреса заявника"});
        let elementAdress = this.createElement('div', { className: 'elementAdress element'}, elementAdress__caption, elementAdress__content);
        
        let elementСontent__content = this.createElement('div', { className: 'elementСontent__content content', innerText: ""+currentEmployeeData.question_content+""});
        let elementСontent__caption = this.createElement('div', { className: 'elementСontent__caption caption', innerText: "Зміст"});
        let elementСontent = this.createElement('div', { className: 'elementСontent element'}, elementСontent__caption, elementСontent__content);
        
        let elementBalance__content = this.createElement('div', { className: 'elementBalance__content content', innerText: ""+currentEmployeeData.balans_name+""});
        let elementBalance__caption = this.createElement('div', { className: 'elementBalance__caption caption', innerText: "Балансоутримувач"});
        let elementBalance = this.createElement('div', { className: 'elementСontent element'}, elementBalance__caption, elementBalance__content);
        
        let elementsWrapper  = this.createElement('div', { className: 'elementsWrapper'}, elementAdress, elementСontent, elementBalance);
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
    createElement: function(tag, props, ...children) {
        const element = document.createElement(tag);
        Object.keys(props).forEach( key => element[key] = props[key] );
        if(children.length > 0){
            children.forEach( child =>{
                element.appendChild(child);
            });
        } return element;
    },     
    changeOnTable: function(message){
        if(message.value != ''){
            document.getElementById('searchTable').style.display = 'block';
            this.config.query.parameterValues = [
                { key: '@appealNum',  value: message.value},
                { key: '@organization_id', value: message.orgId}
                ];
            this.loadData(this.afterLoadDataHandler);
            
            this.dataGridInstance.onCellClick.subscribe(e => {
                if(e.column.dataField == "registration_number" && e.row != undefined){
                    window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/Assignments/edit/"+e.key+"");
                }
            });
        }
    },
    hideAllTable: function(){
        document.getElementById('searchTable').style.display = 'none';
    },    
    hideSearchTable: function(message){
        document.getElementById('searchTable').style.display = 'none';
        document.getElementById('searchContainer__input').value = '';
    },
	afterLoadDataHandler: function(data) {
		this.render();
	},	    
    destroy: function() {
        this.sub.unsubscribe();
        this.sub1.unsubscribe();
        this.sub2.unsubscribe();
    }
};
}());
