(function () {
  return {
    config: {
        query: {
            code: 'ak_QueryCodeSearch',
            parameterValues: [{ key: '@param1', value: '1=1'}],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'question_registration_number',
                caption: 'Номер питання'
            }, {
                dataField: 'question_question_type',
                caption: 'Тип питання',
            }, {
                dataField: 'zayavnyk_full_name',
                caption: 'ПІБ Заявника'
            }, {
                dataField: 'zayavnyk_building_number',
                caption: 'Будинок'
            }, {
                dataField: 'zayavnyk_flat',
                caption: 'Квартира'
            }, {
                dataField: 'question_object',
                caption: "Об'єкт"
            }, {
                dataField: 'assigm_executor_organization',
                caption: 'Виконавець'
            }, {
                dataField: 'registration_date',
                caption: 'Поступило'
            }
        ],
        allowColumnResizing: true,
        columnResizingMode: "widget",
        columnMinWidth: 50,
        columnAutoWidth: true,
        pager: {
            showPageSizeSelector: true,
            allowedPageSizes: [5, 10, 15],
            showInfo: true,
        },
        paging: {
            pageSize: 10
        },
        export: {
            enabled: true,
            fileName: 'File_name'
        },
        showBorders: false,
        showColumnLines: false,
        showRowLines: true,
    },
    myFunc: function(e) {
            var toolbarItems = e.toolbarOptions.items;

            toolbarItems.push({
                widget: "dxButton", 
                options: { 
                    icon: "search",
                    type: "default",
                    text: "Пошук",
                    onClick: function(e) { 
                         this.findAllCheckedFilter();
                    }.bind(this)
                },
                location: "after"
            });
            
            toolbarItems.push({
                widget: "dxButton", 
                options: { 
                    icon: "preferences",
                    type: "default",
                    text: "Налаштування фiльтрiв",
                    onClick: function(e) { 
                        this.messageService.publish( { name: 'clickOnFiltersBtn'});
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
    filtersValuesMacros: [],
    textFilterMacros: '',
    init: function() {
        this.sub = this.messageService.subscribe( 'GlobalFilterChanged', this.setFiltersValue, this );
        // this.sub1 = this.messageService.subscribe( 'renderTable', this.findAllCheckedFilter, this );
        this.sub = this.messageService.subscribe( 'findFilterColumns', this.reloadTable, this );
        this.loadData(this.afterLoadDataHandler);
        this.config.onToolbarPreparing = this.myFunc.bind(this);
        
        this.dataGridInstance.onCellClick.subscribe( function(e) {
            if(e.column.dataField == "question_registration_number" && e.row != undefined){
                this.goToSection('Assignments/edit/'+e.key+'');
            }
        }.bind(this));
    },
    setFiltersValue:function(message) {

        this.filtersValues = [];
        this.filtersValuesMacros = [];
        var elem = message.package.value.values;
        elem.forEach( elem => { 
            if( elem.value == true){
                // this.createObj( elem.name, 0, elem.value); 
                this.createObjMacros( elem.name, '=', 'true'); 
            }
            if(elem.value != ''){
                if( elem.value == null ){
                    // done --->>>
                    filterValue = null;
                }else{
                    if( elem.value.length > 0 ){
                        // this.createObj( elem.name, 6, elem.value); 
                        this.createObjMacros( elem.name, 'like', elem.value); 
                    }
                    if( elem.value.value){
                        if( Number.isInteger(elem.value.value)){
                            this.createObjMacros( elem.name, '==', elem.value.value); 
                        }else{
                            this.createObjMacros( elem.name, '=', elem.value.value); 
                        }
                        // this.createObj( elem.name, 0, elem.value.value); 
                    }else{
                        if( elem.value.dateFrom != undefined  && elem.value.dateFrom != ''){
                            // this.createObj(elem.name+'_from', 1, checkDateFrom(elem.value));
                            this.createObjMacros(elem.name, '>=', checkDateFrom(elem.value));
                        }
                        if( elem.value.dateTo != undefined  && elem.value.dateTo != ''){
                            // this.createObj(elem.name+'_to', 2, checkDateTo(elem.value));
                            this.createObjMacros(elem.name, '<=', checkDateTo(elem.value));
                        }
                    } 
                }
            }
        });
        function checkDateFrom(val){
            return val ? val.dateFrom : null;
        };
        function checkDateTo(val){
            return val ? val.dateTo : null;
        };
    },
    createObj: function(name, operation, value ){
        let obj = {
            code: name,
            operation: operation,
            value: value
        }
        this.filtersValues.push(obj);
    },
    createObjMacros: function(name, operation, value){
        let obj = {
            code: name,
            operation: operation,
            value: value
        }
        this.filtersValuesMacros.push(obj);
    },
    findAllCheckedFilter: function(){
        // let filters = this.filtersValues;
        // this.config.query.filterColumns = [];
        // this.setFilterColumns( el.code, el.operation, el.value);
        // console.log(this.config.query.filterColumns);
        
        let filters = this.filtersValuesMacros;
        if( filters.length > 0 ){
            
            this.textFilterMacros = [];
            filters.forEach( function(el){
              this.createFilterMacros( el.code, el.operation, el.value);
            }.bind(this));
            
            let arr = this.textFilterMacros;
            let str = arr.join(' ');
            let macrosValue = str.slice(0, -4);
            console.log(macrosValue);
            
            this.messageService.publish( { 
                name: 'filters',
                value: this.filtersValuesMacros
            });
            
            this.config.query.parameterValues = [ {  key: '@param1', value: macrosValue } ];
            this.loadData(this.afterLoadDataHandler);
        }else{
            this.config.query.parameterValues = [{ key: '@param1', value: '1=1'}];
            this.loadData(this.afterLoadDataHandler);
            
            this.messageService.publish( { 
                name: 'filters',
                value: this.filtersValuesMacros
            });
        }
        
    },
    createFilterMacros: function(code, operation, value){
        if( operation == 'like' ){
            var textMacros = ""+code+" "+operation+" '%"+value+"%' and";
        }else if(  operation == '=='){
            var textMacros = ""+code+" "+'='+" "+value+" and";
        }else if(  operation == '='){
            var textMacros = ""+code+" "+operation+" N'"+value+"' and";
        }else if( operation == '>=' || operation == '<=' ){
            
            let currentDate = value;
            let year = currentDate.getFullYear();
            let month = currentDate.getMonth();
            let date = currentDate.getDate();
            
            let monthStr = month.toString();
            if(monthStr.length == 1 ){
                month = '0'+monthStr;
            }
            let dateStr = date.toString()
            if(dateStr.length == 1 ){
                date = '0'+dateStr;
            }
            value = ''+year+'-'+month+'-'+date+''; 
            var textMacros = ""+code+" "+operation+" N'"+value+"' and";
        }
        this.textFilterMacros.push(textMacros);
    },
    setFilterColumns: function(code, operation, value) {
        const filter = {
                key: code,
                value: {
                    operation: operation,
                    not: false,
                    values: value
                }
            };
        this.config.query.filterColumns.push(filter);
    },
    reloadTable: function(message){
        this.config.columns = [];
        
        this.config.columns = [
            {
                dataField: 'question_registration_number',
                caption: 'Номер питання',
                width: 120
            }, {
                dataField: 'question_question_type',
                caption: 'Тип питання', 
                width: 250
            }, {
                dataField: 'zayavnyk_full_name',
                caption: 'ПІБ Заявника',
                width: 250               
            }, {
                dataField: 'zayavnyk_building_number',
                caption: 'Будинок',
                width: 250               
            }, {
                dataField: 'zayavnyk_flat',
                caption: 'Квартира',
                width: 60               
            }, {
                dataField: 'question_object',
                caption: "Об'єкт",
                width: 250               
            }, {
                dataField: 'assigm_executor_organization',
                caption: 'Виконавець',
                width: 100               
            }, {
                dataField: 'registration_date',
                caption: 'Поступило',
                width: 100               
            }
        ]
        message.value.forEach(function(el){
            let column = {
                dataField: el.displayValue,
                caption: el.caption,
                width: el.width
            }
            this.config.columns.push(column)
        }.bind(this));
        this.loadData(this.afterLoadDataHandler);
    },
    afterLoadDataHandler: function(data) {
        this.render();
        
        this.createCustomStyle();
    },
    createCustomStyle: function(){
        // document.querySelector('.dx-datagrid-headers').style.fontWeight = 600;
        // document.querySelector('.dx-datagrid-headers').style.backgroundColor = '#eeebebf7';
        // document.querySelector('.dx-icon-export-excel-button').style.color = '#fff';
        // document.querySelector('.dx-icon-export-excel-button').style.marginRight = '9px';

        let element = document.querySelector('.dx-datagrid-export-button');
        let spanElement = this.createElement('span', { className: 'dx-button-text', innerText: 'Excel'});
        element.firstElementChild.appendChild(spanElement);
        
        
        // element.addEventListener('mouseover',  e => {
        //   document.querySelector('.dx-datagrid-export-button').style.backgroundColor = '#449d44';
        // });
        // element.addEventListener('mouseout',  e => {
        //   document.querySelector('.dx-datagrid-export-button').style.backgroundColor = '#5cb85c';
        // });
    },
};
}());
