(function () {
  return {
    config: {
        query: {
            code: 'ProstrocheniUvagaVRoboti',
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
                dataField: 'receipt_date',
                caption: 'Дата надходження',
                dataType: "datetime",
                format: "dd.MM.yyyy HH:mm"
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
                sortOrder: 'desc',
                dataType: "datetime",
                format: "dd.MM.yyyy HH:mm"              
            }
        ],
	    masterDetail: {
            enabled: true,
        },
        pager: {
            showPageSizeSelector:  true,
            allowedPageSizes: [10, 15, 30],
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
    init: function() {
        this.dataGridInstance.height = window.innerHeight - 300;
        document.getElementById('table6__ProstrocheniUvagaVRoboti').style.display = 'none';
        this.sub = this.messageService.subscribe('clickOnTable2', this.changeOnTable, this);
        
        this.config.onToolbarPreparing = this.createTableButton.bind(this);
        this.config.masterDetail.template = this.createMasterDetail.bind(this);
        this.dataGridInstance.onCellClick.subscribe(e => {
            if(e.column.dataField == "registration_number" && e.row != undefined){
                window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/Assignments/edit/"+e.key+"");
            }
        });
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
                    e.event.stopImmediatePropagation();
                    this.exportToExcel();
                }.bind(this)
            },
            location: "after"
        });  
    },
    exportToExcel: function(){
        let exportQuery = {
            queryCode: 'ProstrocheniUvagaVRoboti',
            limit: -1,
            parameterValues: [
                    { key: '@organization_id',  value: this.orgId},
                    { key: '@organizationName', value: this.orgName},
                    { key: '@column', value: this.column},
                    { key: '@navigation', value: this.navigation}
            ]
        };
        this.queryExecutor(exportQuery, this.myCreateExcel, this);
    },
    myCreateExcel: function(data){
        this.showPagePreloader('Зачекайте, формується документ');
        this.indexArr = [];

        let column_registration_number = { name: 'registration_number', index: 0 };
        let column_zayavnyk = { name: 'zayavnyk', index: 1 };
        let column_ZayavnykZmist = { name: 'zayavnyk_zmist', index: 2 };
        let column_vykonavets = { name: 'vykonavets', index: 3 };
        let column_adress = { name: 'adress', index: 4 };
        this.indexArr = [ column_registration_number, column_zayavnyk, column_ZayavnykZmist, column_vykonavets, column_adress];
        
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

        indexArr.forEach( el => {
            if( el.name === 'registration_number'){
                var obj =  {
                    key: 'registration_number',
                    width: 10,
                    height: 20,
                };
                columnsHeader.push(obj);
                captions.push('Номер, дата, час');
            }else if(el.name === 'zayavnyk_zmist'){
                var obj =  { 
                    key: 'zayavnyk_zmist',
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
        let indexControlDate = data.columns.findIndex(el => el.code.toLowerCase() === 'control_date' );
        let indexVykonavets = data.columns.findIndex(el => el.code.toLowerCase() === 'vykonavets' );
        let indexQuestionId = data.columns.findIndex(el => el.code.toLowerCase() === 'questionid' );
        let indexZayavnikId = data.columns.findIndex(el => el.code.toLowerCase() === 'zayavnikid' );
        let indexShortAnswer = data.columns.findIndex(el => el.code.toLowerCase() === 'short_answer' );
        let indexQuestionContent = data.columns.findIndex(el => el.code.toLowerCase() === 'zayavnyk_zmist' );
        let indexAdressZ = data.columns.findIndex(el => el.code.toLowerCase() === 'zayavnyk_adress' );
        let indexRegistrDate = data.columns.findIndex(el => el.code.toLowerCase() === 'ass_registration_date' );
        let indexTransferOrgId = data.columns.findIndex(el => el.code.toLowerCase() === 'transfer_to_organization_id' );
        let indexTransferOrgName = data.columns.findIndex(el => el.code.toLowerCase() === 'transfer_to_organization_name' );             
        let indexReceiptDate = data.columns.findIndex(el => el.code.toLowerCase() === 'receipt_date' );             

        for( let  j = 0; j < data.rows.length; j ++ ){  
            
            var row = data.rows[j];
            var rowArr = [];
            var rowItem = { number: j + 1 };
            for( i = 0; i < indexArr.length; i ++){
                var el = indexArr[i];
                
                if( el.name === 'registration_number'  ){
                    rowItem.registration_number = row.values[indexRegistrationNumber] + '. Надійшло: ' +  this.changeDateTimeValues(row.values[indexReceiptDate]);
                }else if(el.name === 'zayavnyk' ){
                    rowItem.zayavnyk = row.values[indexZayavnikName] + ', ' + row.values[indexAdressZ];
                }else if(el.name === 'zayavnyk_zmist' ){
                    rowItem.zayavnyk_zmist = 'Зміст: ' + row.values[indexQuestionContent];
                }else if( el.name === 'vykonavets'  ){
                    rowItem.vykonavets = row.values[indexVykonavets] + '. ' + 'Дата контролю: ' + this.changeDateTimeValues(row.values[indexControlDate]);
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
                zayavnyk_zmist: el.zayavnyk_zmist,
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
    changeDateTimeValues: function(value){
        
        let date = new Date(value);
        let dd = date.getDate();
        let MM = date.getMonth();
        let yyyy = date.getFullYear();
        let HH = date.getUTCHours()
        let mm = date.getMinutes();
        if( (dd.toString()).length === 1){  dd = '0' + dd; }
        if( (MM.toString()).length === 1){ MM = '0' + (MM + 1); }
        if( (HH.toString()).length === 1){  HH = '0' + HH; }
        if( (mm.toString()).length === 1){ mm = '0' + mm; }
        let trueDate = dd+'.'+MM+'.' + yyyy;
        return trueDate;
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
        if(currentEmployeeData.elementBalance == null || currentEmployeeData.elementBalance == undefined){
            currentEmployeeData.elementBalance = '';
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
        
        let elementsWrapper  = this.createElement('div', { className: 'elementsWrapper'}, elementAdress, elementСontent,  elementBalance);
        container.appendChild(elementsWrapper);
        
        let elementsAll = document.querySelectorAll('.element');
        elementsAll = Array.from(elementsAll);
        elementsAll.forEach( el => {
            el.style.display = 'flex';
            el.style.margin = '15px 10px';
        })
        let elementsCaptionAll = document.querySelectorAll('.caption');
        elementsCaptionAll = Array.from(elementsCaptionAll);
        elementsCaptionAll.forEach( el => {
            el.style.minWidth = '200px';
        })
    },    
    changeOnTable: function(message){
        if(message.column != 'Прострочені' &&  message.column != 'Увага' && message.column != 'В роботі'){
            document.getElementById('table6__ProstrocheniUvagaVRoboti').style.display = 'none';
            
        }else{
            this.orgId =  message.orgId;
            this.orgName =  message.orgName;
            this.column =  message.column;
            this.navigation =  message.navigation;
            document.getElementById('table6__ProstrocheniUvagaVRoboti').style.display = 'block';

            this.config.query.parameterValues = [{ key: '@organization_id',  value: message.orgId},
                                                 { key: '@organizationName', value: message.orgName},
                                                 { key: '@column', value: message.column},
                                                 { key: '@navigation', value: message.navigation}];
           this.loadData(this.afterLoadDataHandler);          
        }
    },
	afterLoadDataHandler: function(data) {
		this.render();
		this.createCustomStyle();
	}, 
    createCustomStyle: function(){
        let elements = document.querySelectorAll('.dx-datagrid-export-button');
        elements = Array.from(elements);
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
