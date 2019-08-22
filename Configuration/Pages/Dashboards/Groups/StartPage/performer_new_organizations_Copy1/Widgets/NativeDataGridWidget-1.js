(function () {
  return {
    config: {
        query: {
            code: 'Nadiyshlo',
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
                fixed: true,
                width: 150
            }, {
                dataField: 'ass_registration_date',
                caption: 'Дата надходження',
                dataType: "datetime",
                format: "dd.MM.yyyy HH:mm",                
                fixed: true,
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
        masterDetail: {
            enabled: true,
        },
        filterRow: {
            visible: true,
            applyFilter: "auto"
        },
        pager: {
            showPageSizeSelector:  true,
            allowedPageSizes: [5, 10, 15, 30],
            showInfo: true,
        },
        paging: {
            pageSize: 10
        },        
        scrolling: {
            mode: 'standart',
            rowRenderingMode: null,
            columnRenderingMode: null,
            showScrollbar: null
        },
        searchPanel: {
            visible: false,
            highlightCaseSensitive: true
        },
        selection: {
            mode: "multiple"
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
        onRowUpdating: function(data) {},
        onRowExpanding: function(data) {},
        onRowInserting: function(data) {},
        onRowRemoving: function(data) {},
        onCellClick: function(data) {},
        onRowClick: function(data) {},
        selectionChanged: function(data) {}
    },
    sub: [],
    sub1: [],
    containerForChackedBox: [],
    init: function() {
        document.getElementById('table4__arrived').style.display = 'none';
        this.sub = this.messageService.subscribe('clickOnTable2', this.changeOnTable, this);
        this.sub1 = this.messageService.subscribe('messageWithOrganizationId', this.orgIdDistribute, this);
        
        this.config.onToolbarPreparing = this.createTableButton.bind(this);
        this.config.masterDetail.template = this.createMasterDetail.bind(this);
        this.dataGridInstance.onCellClick.subscribe(e => {
            if(e.column.dataField == "registration_number" && e.row != undefined){
                window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/Assignments/edit/"+e.key+"");
            }
        });
    },
    changeOnTable: function(message){
        this.column = message.column;
        this.navigator = message.navigation;
        this.targetId = message.targetId;
        this.orgId = message.orgId;
        this.orgName = message.orgName;
        if(message.column != 'Надійшло'){
            document.getElementById('table4__arrived').style.display = 'none';
        }else {
            document.getElementById('table4__arrived').style.display = 'block';

            this.config.query.parameterValues = [{ key: '@organization_id',  value: message.orgId},
                                                 { key: '@organizationName', value: message.orgName},
                                                 { key: '@navigation', value: message.navigation}];
            this.loadData(this.afterLoadDataHandler);          
        }
    },
    findAllSelectRowsToArrived: function(message){
        let rows = this.dataGridInstance.selectedRowKeys;
        if( rows.length > 0 ){
                
            let arrivedSendValueRows = rows.join(', ');
            let executeQuery = {
                queryCode: 'Button_Nadiishlo_VzyatyVRobotu',
                parameterValues: [ {key: '@Ids', value: arrivedSendValueRows} ],
                limit: -1
            };
            this.queryExecutor(executeQuery);
            this.loadData(this.afterLoadDataHandler);
            this.messageService.publish( { name: 'reloadMainTable', column: this.column,   navigator: this.navigator, targetId: this.targetId });
        }
    },
    createTableButton: function(e) {
        var toolbarItems = e.toolbarOptions.items;

        toolbarItems.push({
            widget: "dxButton", 
            options: { 
                icon: "exportxlsx",
                type: "default",
                text: "Excel",
                onClick: function(e) { 
                     this.exportToExcel();
                }.bind(this)
            },
            location: "after"
        });  
        
        toolbarItems.push({
            widget: "dxButton", 
            options: { 
                icon: "check",
                type: "default",
                text: "Взяти в роботу",
                onClick: function(e) { 
                     this.findAllSelectRowsToArrived();
                }.bind(this)
            },
            location: "after"
        });
    },
    exportToExcel: function(){
        let exportQuery = {
            queryCode: 'Nadiyshlo',
            limit: -1,
            parameterValues: [
                    { key: '@organization_id',  value: this.orgId},
                    { key: '@organizationName', value: this.orgName},
                    { key: '@navigation', value: this.navigator}
                ]
        };
        this.queryExecutor(exportQuery, this.myCreateExcel, this);
    },
    myCreateExcel: function(data){
        console.log(data)
        this.showPagePreloader('Зачекайте, формується документ');
        this.indexArr = [];

        let column_registration_number = { name: 'registration_number', index: 0 };
        let column_zayavnyk = { name: 'zayavnyk', index: 1 };
        let column_QuestionType = { name: 'QuestionType', index: 2 };
        let column_vykonavets = { name: 'vykonavets', index: 3 };
        let column_adress = { name: 'adress', index: 4 };
        this.indexArr = [ column_registration_number, column_zayavnyk, column_QuestionType, column_vykonavets, column_adress];
        
        const workbook = this.createExcel();
        const worksheet = workbook.addWorksheet('«Заявки2018', {
            pageSetup:{
                orientation: 'landscape',
                fitToPage: false,
            }
        });
        worksheet.pageSetup.margins = {
            left: 0.4, right: 0.3,
            top: 0.4, bottom: 0.4,
            header: 0.0, footer: 0.0
        };
        /*TITLE*/
        let cellInfoCaption = worksheet.getCell('A1');
        cellInfoCaption.value = 'Інформація';
        let cellInfo = worksheet.getCell('A2');
        cellInfo.value = 'про звернення громадян, що надійшли до Контактного центру  міста Києва. Термін виконання …';
        let cellPeriod = worksheet.getCell('A3');
        cellPeriod.value = 'Період вводу з (включно) : дата з … дата по … .';
        let cellNumber = worksheet.getCell('A4');
        cellNumber.value = 'Реєстраційний № РДА …';
        worksheet.mergeCells('A1:F1'); //вставить другой конец колонок
        worksheet.mergeCells('A2:F2'); //вставить другой конец колонок
        worksheet.mergeCells('A3:F3'); //вставить другой конец колонок
        worksheet.getRow(1).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
        worksheet.getRow(1).alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getRow(2).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
        worksheet.getRow(2).alignment = { vertical: 'middle', horizontal: 'center' };
        
        worksheet.getRow(3).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
        worksheet.getRow(3).alignment = { vertical: 'middle', horizontal: 'left' };
        worksheet.getRow(4).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
        worksheet.getRow(5).alignment = { vertical: 'middle', horizontal: 'left' };
        
     
        var indexArr = this.indexArr;
        var rows = [];
        var captions = [];
        var columnsHeader = [];
        let columnNumber = { key: 'number', width: 5 }
        columnsHeader.push(columnNumber);
        let rowNumber = '№ з/п';
        captions.push(rowNumber);
        console.log(indexArr);

        indexArr.forEach( el => {
            if( el.name === 'registration_number'){
                var obj =  {
                    key: 'registration_number',
                    width: 10,
                    height: 20,
                };
                columnsHeader.push(obj);
                captions.push('Номер, дата, час');
            }else if(el.name === 'QuestionType'){
                var obj =  { 
                    key: 'QuestionType',
                    width: 44
                };
                columnsHeader.push(obj);
                captions.push('Суть питання');
            }else if(el.name === 'zayavnyk'){
                var obj =  {
                    key: 'zayavnyk',
                    width: 30
                };
                columnsHeader.push(obj);
                captions.push('Заявник');
            }else if( el.name === 'vykonavets'){
                var obj =  { 
                    key: 'vykonavets',
                    width: 16
                };
                columnsHeader.push(obj);
                captions.push('Виконавець');
            }else if( el.name === 'adress'){
                var obj =  { 
                    key: 'adress',
                    width: 21
                };
                columnsHeader.push(obj);
                captions.push('Місце проблеми (Об\'єкт)'); 
            }
        });
        worksheet.getRow(5).values = captions;
        worksheet.columns = columnsHeader;
        this.addetedIndexes = [];
        
        let indexId = data.columns.findIndex(el => el.code.toLowerCase() === 'id' );
        let indexRegistrationNumber = data.columns.findIndex(el => el.code.toLowerCase() === 'registration_number' );
        let indexQuestionType = data.columns.findIndex(el => el.code.toLowerCase() === 'questiontype' );
        let indexZayavnikName = data.columns.findIndex(el => el.code.toLowerCase() === 'zayavnyk' );
        let indexAdress = data.columns.findIndex(el => el.code.toLowerCase() === 'adress' );
        let indexVykonavets = data.columns.findIndex(el => el.code.toLowerCase() === 'vykonavets' );
        let indexQuestionId = data.columns.findIndex(el => el.code.toLowerCase() === 'questionid' );
        let indexZayavnikId = data.columns.findIndex(el => el.code.toLowerCase() === 'zayavnikid' );
        let indexShortAnswer = data.columns.findIndex(el => el.code.toLowerCase() === 'short_answer' );
        let indexQuestionContent = data.columns.findIndex(el => el.code.toLowerCase() === 'zayavnyk_zmist' );
        let indexAdressZ = data.columns.findIndex(el => el.code.toLowerCase() === 'zayavnyk_adress' );
        let indexRegistrDate = data.columns.findIndex(el => el.code.toLowerCase() === 'ass_registration_date' );
        let indexTransferOrgId = data.columns.findIndex(el => el.code.toLowerCase() === 'transfer_to_organization_id' );
        let indexTransferOrgName = data.columns.findIndex(el => el.code.toLowerCase() === 'transfer_to_organization_name' );        
        
        for( let  j = 0; j < data.rows.length; j ++ ){  
            var row = data.rows[j];
            var rowArr = [];
            var rowItem = { number: j + 1 };
            for( i = 0; i < indexArr.length; i ++){
                var el = indexArr[i];
                if( el.name === 'registration_number'  ){
                    rowItem.registration_number = row.values[indexRegistrationNumber] + ', ' + row.values[indexRegistrDate];
                }else if(el.name === 'zayavnyk' ){
                    rowItem.zayavnyk = row.values[indexZayavnikName] + ', ' + row.values[indexAdressZ];
                }else if(el.name === 'QuestionType' ){
                    rowItem.QuestionType = 'Тип питання: ' +  row.values[indexQuestionType] + '. Зміст: ' + row.values[indexQuestionContent];;
                }else if( el.name === 'vykonavets'  ){
                    rowItem.vykonavets = row.values[indexVykonavets]
                }else if( el.name === 'adress'  ){
                    rowItem.adress = row.values[indexAdress];
                }
            };
            rows.push( rowItem );
        };
        rows.forEach( el => {
            let number = el.number + '.'
            var row = {
                number: number,
                registration_number: el.registration_number,
                zayavnyk: el.zayavnyk,
                QuestionType: el.QuestionType,
                vykonavets: el.vykonavets,
                adress: el.adress,
            }
            worksheet.addRow(row);
        });
        for(let  i = 0; i < rows.length + 1; i++ ){
            let number = i + 5 ;
            var row = worksheet.getRow(number);
            row.height = 100;
            worksheet.getRow(number).border = {
                top: {style:'thin'},
                left: {style:'thin'},
                bottom: {style:'thin'},
                right: {style:'thin'}
            };
            worksheet.getRow(number).alignment = { 
                vertical: 'middle',
                horizontal: 'center',
                wrapText: true 
            };
            worksheet.getRow(number).font = {
                name: 'Times New Roman',
                family: 4, size: 10,
                underline: false,
                bold: false ,
                italic: false
            };
        };
        
        worksheet.getRow(2).border = {
            bottom: {style:'thin'}
        };
        worksheet.getRow(5).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
        worksheet.getRow(5).alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
        this.helperFunctions.excel.save(workbook, '«Заявки', this.hidePagePreloader);
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
    reloadAfterSend: function(message){
        this.loadData(this.afterLoadDataHandler); 
    },
    createMasterDetail: function(container, options) {
        
        
        debugger;
        
        let newDataGridWrapper  = this.createElement('dx-data-grid', { className: 'dx-widget dx-visibility-change-handler', role: "presentation"} );
        container.appendChild(newDataGridWrapper);
        
        newDataGridWrapper.config = {
            columnAutoWidth: true,
            showBorders: true,
            columns: ["Subject", {
                dataField: "StartDate",
                dataType: "date"
            }, {
                dataField: "DueDate",
                dataType: "date"
            }, "Priority", {
                caption: "Completed",
                dataType: "boolean",
                calculateCellValue: function(rowData) {
                    return rowData.Status == "Completed";
                }
            }],
            
        }
     /*   var currentEmployeeData = options.data;

        if(currentEmployeeData.balans_name == null || currentEmployeeData.balans_name == undefined){
            currentEmployeeData.balans_name = '';
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
        
        let elementBalance__content = this.createElement('div', { className: 'elementBalance__content content', innerText: ""+currentEmployeeData.balans_name+""});
        let elementBalance__caption = this.createElement('div', { className: 'elementBalance__caption caption', innerText: "Балансоутримувач"});
        let elementBalance = this.createElement('div', { className: 'elementСontent element'}, elementBalance__caption, elementBalance__content);
        
        
        let elementsAll = document.querySelectorAll('.element');
        elementsAll.forEach( el => {
            el.style.display = 'flex';
            el.style.margin = '15px 10px';
        })
        let elementsCaptionAll = document.querySelectorAll('.caption');
        elementsCaptionAll.forEach( el => {
            el.style.minWidth = '200px';
        })*/
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
    orgIdDistribute: function(message){
        this.organizationId = message.value;
        this.distribute = message.distribute;
    },
    destroy: function() {
        this.sub.unsubscribe();
        this.sub1.unsubscribe();
    },
};
}());
