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
                dataField: "ForRevision_1Time",
                caption: "Голосіївська РДА"
              }, {
                dataField: "ForRevision_2Times",
                caption: "Дарницька РДА"
              }, {
                dataField: "ForRevision_2Times",
                caption: "Деснянська РДА"
              }, {
                dataField: "ForRevision_2Times",
                caption: "Дніпровська РДА"
              }, {
                dataField: "ForRevision_2Times",
                caption: "Оболонська РДА"
              }, {
                dataField: "ForRevision_2Times",
                caption: "Печерська РДА"
              }, {
                dataField: "ForRevision_2Times",
                caption: "Подільська  РДА"
              }, {
                dataField: "ForRevision_2Times",
                caption: "Святошинська РДА"
              }, {
                dataField: "ForRevision_2Times",
                caption: "Солом`янська РДА"
              }, {
                dataField: "ForRevision_2Times",
                caption: "Шевченківська РДА"
              }, {
                dataField: "ForRevision_2Times",
                caption: "Шевченківська 1312312",
                width: 0
              }
          ],
          keyExpr: 'Id'
      },
      init: function() {
        this.active = false;
        document.getElementById('containerSpeedExplained').style.display = 'none';
        this.sub = this.messageService.subscribe('showTable', this.showTable, this);
        this.sub1 = this.messageService.subscribe('GlobalFilterChanged', this.getFiltersParams, this);
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
              // window.open(location.origin + localStorage.getItem('VirtualPath') + "/dashboard/page/rating_indicator?"+string);
            }
          }
        });
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
