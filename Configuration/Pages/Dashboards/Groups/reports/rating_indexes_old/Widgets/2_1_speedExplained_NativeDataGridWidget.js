(function () {
  return {
      config: {
          query: {
              code: 'db_ReestrRating1',
              parameterValues: [],
              filterColumns: [],
              sortColumns: [],
              skipNotVisibleColumns: true,
              chunkSize: 1000
          },
          columns: [
            {
                dataField: 'RDAId',
                dataType: 'string',
                caption: ' ',
            }, {
                dataField: 'PercentClosedOnTime',
                caption: 'Середнє (еталон)',
                width: 50
            }
          ],
          keyExpr: 'Id',
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
      },
      init: function() {
          this.active = false;
          document.getElementById('containerSpeedExplained').style.display = 'none';
          this.sub = this.messageService.subscribe('showTable', this.showTable, this);
          this.sub1 = this.messageService.subscribe('GlobalFilterChanged', this.getFiltersParams, this);
          this.sub2 = this.messageService.subscribe( 'ApplyGlobalFilters', this.renderTable, this );
      },
      showTable: function(message){
          let tabName = message.tabName;
          if(tabName !== 'tabSpeedExplained'){
              this.active = false;
              document.getElementById('containerSpeedExplained').style.display = 'none';
          }else {
              this.active = true;
              document.getElementById('containerSpeedExplained').style.display = 'block';
              this.renderTable();
          }
      },
      getFiltersParams: function(message){
          let period = message.package.value.values.find(f => f.name === 'period').value;
          let executor = message.package.value.values.find(f => f.name === 'executor').value;
          let rating = message.package.value.values.find(f => f.name === 'rating').value;
          
          if( period !== '' ){
              this.period = period;
              this.executor = executor === null ? 0 :  executor === '' ? 0 : executor.value;
              this.rating = rating === null ? 0 :  rating === '' ? 0 : rating.value;
          }
      }, 
      renderTable: function () {
          if(this.period) {
              if (this.active) {
  
                  let msg = {
                      name: "SetFilterPanelState",
                      package: {
                          value: false
                      }
                  };
                  this.messageService.publish(msg);
                  this.config.query.parameterValues = [ 
                      {key: '@DateCalc' , value: this.period },
                      {key: '@RDAId', value: this.executor },  
                      {key: '@RatingId', value: this.rating } 
                  ];
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