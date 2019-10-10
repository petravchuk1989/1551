(function () {
  return {
    title: ' ',
    hint: '',
    formatTitle: function() {},
    customConfig:
                `
                <style>
                #reportTitle{
                    text-align: center;
                    font-size: 20px;
                    font-weight: 600;
                    margin: 10px;
                }
                #subTitle{
                    text-align: center;
                    font-size: 14px;
                    font-weight: 600;
                }
                .btnWrap{
                    text-align: center;
                }
                #btnExcel{
                    background-color: rgba(21, 189, 244, 1)!important;
                    border-color: transparent;
                    color: #fff;
                    display: inline-block;
                    cursor: pointer;
                    text-align: center;
                    vertical-align: middle;
                    padding: 7px 18px 8px;
                    border-radius: 5px;                        
                    margin: 10px;
                }
                </style>
                
                 <div id='container'></div>
                 
                `
    ,
    init: function() {
        this.sub = this.messageService.subscribe('GlobalFilterChanged', this.getFiltersParams, this );
        this.sub1 = this.messageService.subscribe('setData', this.setData, this );
        this.counter = 0;
    },
    afterViewInit: function(data) {
        const CONTAINER = document.getElementById('container');
        let reportTitle = this.createElement( 'div', { id: 'reportTitle', innerText: 'Звіт для метрополітену' });
        let subTitle = this.createElement( 'div', { id: 'subTitle' });
        CONTAINER.appendChild(reportTitle);
        CONTAINER.appendChild(subTitle);
        subTitle.innerText = 'Статистична інформація за період з '+this.changeDateTimeValues(this.dateFrom)+'до '+this.changeDateTimeValues(this.dateTo)+' Виконавець: КП «Київський метрополітен»';
        this.subTitle = subTitle;
        let btnExcel = this.createElement('button', { id: 'btnExcel', innerText: 'Вигрузити в Excel', disabled: true } );
        let btnWrap = this.createElement('div', { className: 'btnWrap' }, btnExcel );
        CONTAINER.appendChild(btnWrap);
        
        btnExcel.addEventListener('click', event => {
            event.stopImmediatePropagation();
            this.createTableExcel();
        });
        
    },
    getFiltersParams: function(message){
        let period = message.package.value.values.find(f => f.name === 'period').value;
	    if( period !== null ){
    		if( period.dateFrom !== '' && period.dateTo !== ''){
            
                this.dateFrom =  period.dateFrom;
                this.dateTo = period.dateTo;
	        }
	        if(subTitle !== null){
	            subTitle.innerText = 'Статистична інформація за період з '+this.changeDateTimeValues(this.dateFrom)+'до '+this.changeDateTimeValues(this.dateTo)+' Виконавець: КП «Київський метрополітен»';
	        }
	    }
    },
    setData: function(message){
        if( message.rep1_data){
            this.rep1_data =  message.rep1_data;
            this.counter += 1;
        }else if( message.rep2_data){
            this.rep2_data =  message.rep2_data;
            this.counter += 1;
        }
        if( this.counter === 2 ){
            this.dataArray = [ this.rep1_data, this.rep2_data];
            document.getElementById('btnExcel').disabled = false;
            this.counter = 0;
        }
    },
    createTableExcel: function(){
        this.showPagePreloader('Зачекайте, формується документ');
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
        let mainHeaders = [];
        for(let i = 0; i <  this.dataArray.length; i++){
            
            let data =  this.dataArray[i];
            this.indexArr = [];
            let name = { name: 'orgName', index: 0 };
            let counter = { name: 'questionQty', index: 1 };
            this.indexArr = [ name, counter];
        
            let indexArr = this.indexArr;
            let rows = [];
            let captions = [];
            let columnsHeader = [];
            
            indexArr.forEach( el => {
                if( el.name === 'orgName'){
                    let obj =  {
                        key: el.name,
                        width: 44,
                    };
                    columnsHeader.push(obj);
                    captions.push('Назва');
                }else if(el.name === 'questionQty'){
                    let obj =  { 
                        key: el.name,
                        width: 15
                    };
                    columnsHeader.push(obj);
                    captions.push('Кiлькiсть');
                }
            });
            let tds = [];
            let tdsCounter = [];
            
            worksheet.getRow(5).values = captions;
            worksheet.columns = columnsHeader;
            
            if(i === 0){
                let cellInfoCaption = worksheet.getCell('A1');
                cellInfoCaption.value = 'Виконавець: КП «Київський метрополітен»';
                let cellInfo = worksheet.getCell('A2');
                cellInfo.value = 'Статистична інформація за період ';
                let cellPeriod = worksheet.getCell('A3');
                cellPeriod.value = 'з '+this.changeDateTimeValues(this.dateFrom)+'до '+this.changeDateTimeValues(this.dateTo);
                worksheet.mergeCells('A1:B1'); //вставить другой конец колонок
                worksheet.mergeCells('A2:B2'); //вставить другой конец колонок
                worksheet.mergeCells('A3:B3'); //вставить другой конец колонок
                
                worksheet.getRow(1).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
                worksheet.getRow(1).alignment = { vertical: 'middle', horizontal: 'center' };
                
                worksheet.getRow(2).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
                worksheet.getRow(2).alignment = { vertical: 'middle', horizontal: 'center' };
                
                worksheet.getRow(3).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
                worksheet.getRow(3).alignment = { vertical: 'middle', horizontal: 'center' };
                mainHeaders.push(5);
                worksheet.getRow(5).values = captions;
                for(let i = 6; i < (data.length + 6); i++ ){
                    let value = data[i-6];
                    columnText = worksheet.getCell('A'+i);
                    columnCounter = worksheet.getCell('B'+i);
                    columnText.value = value[1];
                    columnCounter.value = value[2];
                    tds.push('A'+i);
                    tdsCounter.push('B'+i);
                }
            }
            else if(i === 1){
                this.rowTable1 = (this.dataArray[0].length + 7);
                mainHeaders.push(this.rowTable1);
                worksheet.getRow(this.rowTable1).values = captions;
                // let data = this.dataArray[0];
                for(let i =  this.rowTable1  + 1 ; i < (data.length + this.rowTable1 + 1 ); i++ ){
                    let value = data[i-( this.rowTable1 + 1)];
                    columnText = worksheet.getCell('A'+i);
                    columnCounter = worksheet.getCell('B'+i);
                    columnText.value = value[1];
                    columnCounter.value = value[2];
                    tds.push('A'+i);
                    tds.push('A'+(i-1) );
                    tdsCounter.push('B'+i);
                    tdsCounter.push('B'+(i-1));
                }
            }
            console.log(tds, tdsCounter);
            for(let  i = 0; i < tds.length; i++ ){
                let td = tds[i];
                worksheet.getCell(td).border = {
                    top: {style:'thin'},
                    left: {style:'thin'},
                    bottom: {style:'thin'},
                    right: {style:'thin'}
                };
                worksheet.getCell(td).alignment = { 
                    vertical: 'middle',
                    horizontal: 'left',
                    wrapText: true 
                };
                worksheet.getCell(td).font = {
                    name: 'Times New Roman',
                    family: 4, size: 10,
                    underline: false,
                    bold: false ,
                    italic: false
                };
            };
            for(let  i = 0; i < tdsCounter.length; i++ ){
                let td = tdsCounter[i];
                worksheet.getCell(td).border = {
                    top: {style:'thin'},
                    left: {style:'thin'},
                    bottom: {style:'thin'},
                    right: {style:'thin'}
                };
                worksheet.getCell(td).alignment = { 
                    vertical: 'middle',
                    horizontal: 'center',
                    wrapText: true 
                };
                worksheet.getCell(td).font = {
                    name: 'Times New Roman',
                    family: 4, size: 10,
                    underline: false,
                    bold: false ,
                    italic: false
                };
            };
            mainHeaders.forEach( number => {
                worksheet.getRow(number).height = 50;
                worksheet.getRow(number).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
                worksheet.getRow(number).alignment = { vertical: 'middle', horizontal: 'center', wrapText: true  };
            });
        }
        worksheet.getCell('A5').border = {  top: {style:'thin'}, left: {style:'thin'}, bottom: {style:'thin'}, right: {style:'thin'} };
        worksheet.getCell('B5').border = {  top: {style:'thin'}, left: {style:'thin'}, bottom: {style:'thin'}, right: {style:'thin'} };
        this.helperFunctions.excel.save(workbook, '«Заявки', this.hidePagePreloader);
    }, 
	changeDateTimeValues: function(value){
        
        let date = new Date(value);
        let dd = date.getDate();
        let MM = date.getMonth();
        let yyyy = date.getFullYear();
        let HH = date.getUTCHours()
        let mm = date.getMinutes();
        MM += 1 ;
        if( (dd.toString()).length === 1){  dd = '0' + dd; }
        if( (MM.toString()).length === 1){ MM = '0' + MM; }
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
    destroy: function(){
        this.sub.unsubscribe();
        this.sub1.unsubscribe();
    },
    
};
}());
