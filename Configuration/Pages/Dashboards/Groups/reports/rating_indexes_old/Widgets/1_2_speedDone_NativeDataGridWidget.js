(function () {
  return {
    config: {
      query: {
        code: "IndexOfSpeedToExecution_Percent",
        parameterValues: [],
        filterColumns: [],
        sortColumns: [],
        skipNotVisibleColumns: true,
        chunkSize: 1000
      },
      columns: [],
      scrolling: {
        mode: 'virtual'
      },
      filterRow: {
          visible: true,
          applyFilter: "auto"
      },
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
      onCellPrepared: function(options) {  
        
        if (options.rowType == 'header'){  
          // options.cellElement.style({ 'transform': 'rotate(90deg)', 'transform-origin': '10% 40%', 'height': '100px' });  

          // options.cellElement.style.transform = 'rotate(270deg)';
          // // options.cellElement.style.position = 'absolute';
          // options.cellElement.style.height = '140px';
          // options.cellElement.style.width = '140px';
          
          // options.cellElement.style.verticalAlignment = 'Center';
          // options.cellElement.style.textAlignment = 'Center';
          // options.cellElement.style.horizontalAlignment = 'Center';

          // debugger;
        }  
      }
    },
    columns: [],
    init: function() {
      this.dataGridInstance.height = window.innerHeight - 200;
      this.active = true;
      let msg = {
        name: "SetFilterPanelState",
        package: {
          value: true
        }
      };
      this.messageService.publish(msg);
      this.sub = this.messageService.subscribe('showTable', this.showTable, this);
      this.sub1 = this.messageService.subscribe('FilterParameters', this.executeQuery, this);
      this.sub2 = this.messageService.subscribe( 'ApplyGlobalFilters', this.renderTable, this );
      
      this.dataGridInstance.onCellClick.subscribe(e => {
        e.event.stopImmediatePropagation();
        if(e.column){
          if(e.row !== undefined){
         
            // Виконавець
            // Дата
            // Рейтинг
            // ИД РДА
            // ИД типу питання
            let executor = this.executor;
            let date = this.period;
            let ratingid = this.rating;
            let rdaid = e.column.dataField;
            let question = e.data.code;
            debugger;
            let string = 'executor='+executor+'&date='+date+'&ratingid='+ratingid+'&rdaid='+rdaid+'&question='+question;
              window.open(location.origin + localStorage.getItem('VirtualPath') + "/dashboard/page/rating_indexes_by_rda_question?"+string);
          }
        }
      });
    },
    showTable: function(message){
      let tabName = message.tabName;
      if(tabName !== 'tabSpeedDone'){
          this.active = false;
          document.getElementById('containerSpeedDone').style.display = 'none';
      }else {
          this.active = true;
          document.getElementById('containerSpeedDone').style.display = 'block';
          this.renderTable();
      }
    },
    setColumns: function (data) {
        for (let i = 0; i < data.columns.length; i++) {
            
            const element = data.columns[i];
            if( element.code !== 'QuestionTypeId') {

                let dataField = element.code;
                let caption = element.name;
                let obj = { dataField, caption }
                this.config.columns.push(obj);
            }
        }   
        this.config.keyExpr = data.columns[0].code;
        this.config.query.parameterValues = this.parameters;
        this.loadData(this.afterLoadDataHandler);
    },
    executeQuery: function (message) {
        this.period = message.period;
        this.rating = message.rating;
        this.executor = message.executor;
        this.parameters = message.parameters;
        let executeQuery = {
            queryCode: this.config.query.code,
            parameterValues: this.parameters,
            limit: -1
        };
        this.queryExecutor(executeQuery, this.setColumns, this);  
    },
    renderTable: function () {
        if (this.period) {
            if (this.active) {
                let msg = {
                    name: "SetFilterPanelState",
                    package: {
                        value: false
                    }
                };
                this.messageService.publish(msg);
                this.config.query.parameterValues = this.parameters;
                this.loadData(this.afterLoadDataHandler);  
            }
        }
    },
    afterLoadDataHandler: function(data) {
        this.render();
    },
    destroy: function () {
        this.sub.unsubscribe();
        this.sub1.unsubscribe();
        this.sub2.unsubscribe();
    }
  };
}());
