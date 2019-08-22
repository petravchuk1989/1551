(function () {
  return {
    config: {
        query: {
            code: 'EventsTable',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'EventId',
                caption: 'Номер заходу',
                fixed: true,
                width: 130,
            },  {
                dataField: 'EventType',
                caption: 'Тип заходу',
                fixed: true,
            },  {
                dataField: 'EventName',
                caption: 'Назва',
                fixed: true,
            },  {
                dataField: 'start_date',
                caption: 'Дата початку',
                fixed: true,
                sortOrder: 'desc',
            },  {
                dataField: 'plan_end_date',
                caption: 'Планова дата закінчення',
                fixed: true,
            },  {
                dataField: 'CountQuestions',
                caption: 'К-ть питань пов`язаних з заходом',
                fixed: true,
            }
        ],
        filterRow: {
            visible: true,
            applyFilter: "auto"
        },        
        export: {
            enabled: false,
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
        keyExpr: 'EventId',
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
        document.getElementById('table_events').style.display = 'none';
        this.sub = this.messageService.subscribe('showEventTable', this.changeOnTable, this);
        this.sub1 = this.messageService.subscribe('search', this.searchRelust, this);
        
        this.dataGridInstance.onCellClick.subscribe(e => {
            if(e.column.dataField == "EventId" && e.row != undefined){
                window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/Events/edit/"+e.key+"");
                // this.goToSection('events//edit/'+e.key+''');
            }
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
        let elementAdress__content = this.createElement('div', { className: 'elementAdress__content content', innerText: ""+currentEmployeeData.zayavnyk_adress+""});
        let elementAdress__caption = this.createElement('div', { className: 'elementAdress__caption caption', innerText: "Адреса заявника"});
        let elementAdress = this.createElement('div', { className: 'elementAdress element'}, elementAdress__caption, elementAdress__content);
        
        let elementСontent__content = this.createElement('div', { className: 'elementСontent__content content', innerText: ""+currentEmployeeData.zayavnyk_zmist+""});
        let elementСontent__caption = this.createElement('div', { className: 'elementСontent__caption caption', innerText: "Зміст"});
        let elementСontent = this.createElement('div', { className: 'elementСontent element'}, elementСontent__caption, elementСontent__content);
        
        let elementComment__content = this.createElement('div', { className: 'elementComment__content content', innerText: ""+currentEmployeeData.short_answer+""});
        let elementComment__caption = this.createElement('div', { className: 'elementComment__caption caption', innerText: "Коментар виконавця"});
        let elementComment = this.createElement('div', { className: 'elementСontent element'}, elementComment__caption, elementComment__content);
        
        
        let elementsWrapper  = this.createElement('div', { className: 'elementsWrapper'}, elementAdress, elementСontent, elementComment);
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
    changeOnTable: function(message){
        console.log ( message.typeEvent, message.source)
        if(message.typeEvent != 'Прострочені' && message.typeEvent != 'Не активні' && message.typeEvent != 'В роботі'){
            document.getElementById('table_events').style.display = 'none';
        }else{
            document.getElementById('table_events').style.display = 'block';
            this.config.query.queryCode = 'EventsTable';
            this.config.query.parameterValues = [{ key: '@organization_id',  value: message.orgId},
                                                 { key: '@OtKuda', value: message.source},
                                                 { key: '@TypeEvent', value: message.typeEvent}];
            this.loadData(this.afterLoadDataHandler); 
        }
    },
	afterLoadDataHandler: function(data) {
		this.render();
	},    
    destroy: function() {
        this.sub.unsubscribe();
        this.sub1.unsubscribe();
    }
};
}());
