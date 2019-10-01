(function () {
  return {
    config: {
        query: {
            code: 'Prozvon_Applicant',
            parameterValues: [],
            filterColumns: [],
            sortColumns: [],
            skipNotVisibleColumns: true,
            chunkSize: 1000
        },
        columns: [
            {
                dataField: 'institutionName',
                caption: 'Назва установи',
            }, {
                dataField: 'registeredInWorkPreviousRevision',
                caption: 'Зареєстровано, В роботі, На доопрацюванні за попередній період',
            }, {
                dataField: 'totalNumberHitsForCurrentMonth',
                caption: 'Загальна кількість звернень за поточний місяць',
            }, {
                dataField: 'registered',
                caption: 'з них, Зареєстровано',
            }, {
                dataField: 'overdue',
                caption: 'з них, Прострочені',
            }, {
                dataField: 'inWork',
                caption: 'з них, В роботі',
            }, {
                caption: 'На перевірці',
                alignItems: 'middle',
                columns: [
                    {
                        dataField: 'testing__isDone_sub1',
                        caption: 'Виконано',
                    }, 
                    {
                        dataField: 'testing__inWork_sub1',
                        caption: 'Роз\'яснено',
                    }, 
                    {
                        dataField: 'testing__notPossiblePerformThisTime_sub1',
                        caption: 'Не можливо виконанти в даний період',
                        width: 50
                    } 
                ]
            }, {
                caption: 'Результат виконання',
                columns: [
                    {
                        dataField: 'done__isDone_sub2',
                        caption: 'Виконано',
                    }, 
                    {
                        dataField: 'done__inWork_sub2',
                        caption: 'Роз\'яснено',
                    }, 
                    {
                        dataField: 'done__revisionTotal_sub2',
                        caption: 'На доопрацювання (Всього )',
                    } 
                ]
            }, {
                caption: 'На доопрацювання (Всього)',
                columns: [
                    {
                        dataField: 'revisionTotal__one_sub3',
                        caption: '1 раз',
                    }, 
                    {
                        dataField: 'revisionTotal__two_sub3',
                        caption: '2 раз',
                    }, 
                    {
                        dataField: 'revisionTotal__three_sub3',
                        caption: '3 раз',
                    }, 
                ]
            }, {
                dataField: 'revisionToday',
                caption: 'На доопрацювання (на сьогодні)',
            }, {
                dataField: 'percentTimelyClosed',
                caption: '% вчасно закритих',
            }, {
                dataField: 'percentRevisionToday',
                caption: '% виконання',
                
            }, {
                dataField: 'percentConfidence',
                caption: '% достовірності',
            }, {
                dataField: 'performanceRateIndex',
                caption: 'Індекс швидкості виконання',
            }, {
                dataField: 'explanationRateIndex',
                caption: 'Індекс швидкості роз\'яснення',
            }, {
                dataField: 'actualPerformanceIndex',
                caption: 'Індекс фактичного виконання',
            }, {
                dataField: 'percentSatisfactionWithPerformance',
                caption: '% задоволеність виконанням',
            }, {
                dataField: 'performanceLevel',
                caption: 'Рівень виконання',
            }, 
        ],
        keyExpr: 'Id',
        columnChooser: {
            enabled: true
        },
        scrolling: {
            mode: 'virtual'
        },
        columnFixing: { 
            enabled: true
        },
        showBorders: false,
        showColumnLines: true,
        showRowLines: true,
        remoteOperations: null,
        allowColumnReordering: null,
        rowAlternationEnabled: null,
        columnAutoWidth: true,
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
    init: function() {
        this.sub = this.messageService.subscribe( 'GlobalFilterChanged', this.getFiltersParams, this );

        this.config.columns.forEach( col => {
            function setColStyles(col){
                col.width = '120';
                col.alignment = 'center';
                col.verticalAlignment = 'Bottom';
            }
            if(col.columns){
                setColStyles(col);
                col.columns.forEach( col => setColStyles(col));
            }else{
                setColStyles(col);
            }
        });
       
        this.config.onContentReady = this.onMyContentReady.bind(this);
        this.config.onToolbarPreparing = this.createTableButton.bind(this);
    },
    getFiltersParams: function(message){
        let period = message.package.value.values.find(f => f.name === 'period').value;
        let executor = message.package.value.values.find(f => f.name === 'executor').value;
        let rating = message.package.value.values.find(f => f.name === 'rating').value;

        if( period !== null ){
            if( period.dateFrom !== '' && period.dateTo !== ''){

                this.dateFrom =  period.dateFrom;
                this.dateTo = period.dateTo;
                this.executor = executor === null ? 0 :  executor === '' ? 0 : executor.value ;
                this.rating = rating === null ? 0 :  rating === '' ? 0 : rating.value ;
                
                this.config.query.parameterValues = [ 
                    {key: '@dateFrom' , value: this.dateFrom },  
                    {key: '@dateTo', value: this.dateTo },  
                    {key: '@executor', value: this.executor },  
                    {key: '@rating', value: this.rating } 
                ];
                this.loadData(this.afterLoadDataHandler);
            }
        }
    },     
    createTableButton: function (e) {
        let toolbarItems = e.toolbarOptions.items;

        toolbarItems.push({
            widget: "dxButton", 
            location: "after",
            options: { 
                icon: "exportxlsx",
                type: "default",
                text: "Excel",
                onClick: function(e) {
                    e.event.stopImmediatePropagation();
                    // let exportQuery = {
                    //     queryCode: 'db_Report_3',
                    //     limit: -1,
                    //     parameterValues: [
                    //         {key: '@dateFrom' , value: this.dateFrom },  
                    //         {key: '@dateTo', value: this.dateTo }, 
                    //         {key: '@questionGroup', value: this.questionGroup }, 
                    //         {key: '@questionType', value: this.questionType }, 
                    //     ]
                    // };
                    // this.queryExecutor(exportQuery, this.myCreateExcel, this);
                    this.myCreateExcel();
                }.bind(this)
            },
        });
    },
    myCreateExcel: function (data) {
        this.showPagePreloader('Зачекайте, формується документ');
        let columns = this.visibleColumns;
        this.indexes1Length = 0;
        this.indexes2Length  = 0;
        this.indexes3Length  = 0;
        this.sub1ColIndex = 0;
        this.sub2ColIndex = 0;
        this.sub3ColIndex = 0;
        this.columnsWithoutSub = [];
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

        let cellInfoCaption = worksheet.getCell('A1');
        cellInfoCaption.value = 'Показники рейтингів';
        let cellInfoDate = worksheet.getCell('A2');
        cellInfoDate.value = 'з: ' + this.changeDateTimeValues(this.dateFrom)+' , по: ' + + this.changeDateTimeValues(this.dateTo);
        
        worksheet.mergeCells(1,columns.length,1,1); // top,left,bottom,right
        worksheet.mergeCells(2,columns.length,2,1); // top,left,bottom,right
        worksheet.mergeCells(3,columns.length,3,1); // top,left,bottom,right

        worksheet.getRow(1).font = { name: 'Times New Roman', family: 4, size: 16, underline: false, bold: true , italic: false};
        worksheet.getRow(1).alignment = { vertical: 'middle', horizontal: 'center' };
        worksheet.getRow(2).font = { name: 'Times New Roman', family: 4, size: 16, underline: false, bold: true , italic: false};
        worksheet.getRow(2).alignment = { vertical: 'middle', horizontal: 'center' };

        let captions = [];
        let columnsHeader = [];      
        for (let i = 0; i < columns.length; i++) {
            let column = columns[i];
            let caption = column.caption;
            captions.push(caption);

            let header = column.caption;
            let key = column.dataField;
            let width = 15;
            let index = 10;
            let columnProp = { header, key, width, index };
            columnsHeader.push(columnProp);    
        }
       
        worksheet.columns = columnsHeader;
        worksheet.getRow(5).values = captions;
        worksheet.getRow(5).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
        worksheet.getRow(4).font = { name: 'Times New Roman', family: 4, size: 10, underline: false, bold: true , italic: false};
        worksheet.getRow(5).alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
        worksheet.getRow(4).alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
        worksheet.getRow(4).height = 70;
        worksheet.getRow(5).height = 70;

        // for(let  i = 0; i < rows.length + 1; i++ ){
        //     let number = i + 5 ;
        //     let row = worksheet.getRow(number);
        //     row.height = 100;
        //     worksheet.getRow(number).border = {
        //         top: {style:'thin'},
        //         left: {style:'thin'},
        //         bottom: {style:'thin'},
        //         right: {style:'thin'}
        //     };
        //     worksheet.getRow(number).alignment = { 
        //         vertical: 'middle',
        //         horizontal: 'center',
        //         wrapText: true 
        //     };
        //     worksheet.getRow(number).font = {
        //         name: 'Times New Roman',
        //         family: 4, size: 10,
        //         underline: false,
        //         bold: false ,
        //         italic: false
        //     };
        // };


        for (let i = 0; i < columns.length; i++) {
            let column = columns[i];
            let key = column.dataField;
            let caption = column.caption;
            let subStr = key.slice(-5, -1);
            let colIndexFrom = i+1;
            if( subStr === '_sub'){
                let subIndex = key.slice(-1);

                if(+subIndex === 1){
                    this.indexes1Length++;
                    this.sub1ColIndex = this.sub1ColIndex === 0 ?  colIndexFrom : this.sub1ColIndex;
                }else if(+subIndex === 2){
                    this.indexes2Length++;
                    this.sub2ColIndex = this.sub2ColIndex === 0 ?  colIndexFrom : this.sub2ColIndex;
                }else if(+subIndex === 3){
                    this.indexes3Length++;
                    this.sub3ColIndex = this.sub3ColIndex === 0 ?  colIndexFrom : this.sub3ColIndex;
                }              
                var indexCaptionFrom = 5;
            }else{
                let column = { caption, colIndexFrom }
                var indexCaptionFrom = 4;

                this.columnsWithoutSub.push(column);
            }
            worksheet.mergeCells(indexCaptionFrom, colIndexFrom, 5, colIndexFrom );
        }  
        worksheet.mergeCells( 4, this.sub1ColIndex, 4, (this.sub1ColIndex + this.indexes1Length - 1) );
        worksheet.mergeCells( 4, this.sub2ColIndex, 4, (this.sub2ColIndex + this.indexes2Length - 1) );
        worksheet.mergeCells( 4, this.sub3ColIndex, 4, (this.sub3ColIndex + this.indexes3Length - 1) );
        let sub1Caption = worksheet.getCell(4, this.sub1ColIndex);
        sub1Caption.value = 'На перевірці';
        let sub2Caption = worksheet.getCell(4, this.sub2ColIndex);
        sub2Caption.value = 'Результат виконання';
        let sub3Caption = worksheet.getCell(4, this.sub3ColIndex);
        sub3Caption.value = 'На доопрацювання (Всього)';


        for (let i = 0; i < this.columnsWithoutSub.length; i++) {
            let element = this.columnsWithoutSub[i];
            let caption = worksheet.getCell(4, element.colIndexFrom);
            caption.value = element.caption;
        }

        this.helperFunctions.excel.save(workbook, '«Заявки', this.hidePagePreloader);
    },
    changeDateTimeValues: function(value){
        
        let date = new Date(value);
        let dd = date.getDate();
        let MM = date.getMonth();
        let yyyy = date.getFullYear();
        let HH = date.getHours();
        let mm = date.getMinutes();
        if( (dd.toString()).length === 1){  dd = '0' + dd; }
        if( (MM.toString()).length === 1){ MM = '0' + (MM + 1); }
        if( (HH.toString()).length === 1){  HH = '0' + HH; }
        if( (mm.toString()).length === 1){ mm = '0' + mm; }
        let trueDate = dd+'.'+MM+'.' + yyyy +' '+ HH +':'+ mm;
        return trueDate;
    },  
    afterLoadDataHandler: function(data) {
        this.render();
    },
    onMyContentReady: function () {
        this.visibleColumns = this.dataGridInstance.instance.getVisibleColumns();
    },
    createCustomStyle: function() {

    }, 
};
}());
