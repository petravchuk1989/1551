(function () {
  return {
    config: {
      query: {
        code: "db_ReestrRating1",
        parameterValues: [],
        filterColumns: [],
        sortColumns: [],
        skipNotVisibleColumns: true,
        chunkSize: 1000
      },
      columns: [
        {
          dataField: "ForRevision_1Time",
          caption: "Голосіївська РДА",
          width: 140
        }, {
          dataField: "ForRevision_2Times",
          caption: "Дарницька РДА",
          width: 140
        }, {
          dataField: "ForRevision_2Times",
          caption: "Деснянська РДА",
          width: 140
        }, {
          dataField: "ForRevision_2Times",
          caption: "Дніпровська РДА",
          width: 140
        }, {
          dataField: "ForRevision_2Times",
          caption: "Оболонська РДА",
          width: 140
        }, {
          dataField: "ForRevision_2Times",
          caption: "Печерська РДА",
          width: 140
        }, {
          dataField: "ForRevision_2Times",
          caption: "Подільська  РДА",
          width: 140
        }, {
          dataField: "ForRevision_2Times",
          caption: "Святошинська РДА",
          width: 140
        }, {
          dataField: "ForRevision_2Times",
          caption: "Солом`янська РДА",
          width: 140
        }, {
          dataField: "ForRevision_2Times",
          caption: "Шевченківська РДА",
          width: 140
        }
      ],
      keyExpr: "Id",
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
    init: function() {
      this.active = true;
      let msg = {
        name: "SetFilterPanelState",
        package: {
          value: true
        }
      };
      this.messageService.publish(msg);
      this.sub = this.messageService.subscribe("showTable",this.showTable,this);
      this.sub1 = this.messageService.subscribe("GlobalFilterChanged",this.getFiltersParams,this);
      this.sub2 = this.messageService.subscribe("ApplyGlobalFilters",this.renderTable,this);

      this.dataGridInstance.onCellClick.subscribe(e => {
        e.event.stopImmediatePropagation();
        if(e.column){
          if(e.row !== undefined){

            debugger;
            let rdaid = e.data.RDAId;
            let ratingid = e.data.RatingId;
            let columncode = e.column.dataField;
            let date = this.period;
            let string = 'rdaid='+rdaid+'&ratingid='+ratingid+'&columncode='+columncode+'&date='+date;
            // window.open(location.origin + localStorage.getItem('VirtualPath') + "/dashboard/page/district_rating_indicator?"+string);
          }
        }
      });
    },
    showTable: function(message) {
      let tabName = message.tabName;
      if (tabName !== "tabSpeedDone") {
        this.active = false;
        document.getElementById("containerSpeedDone").style.display = "none";
      } else {
        this.active = true;
        document.getElementById("containerSpeedDone").style.display = "block";
        this.renderTable();
      }
    },
    getFiltersParams: function(message) {
      let period = message.package.value.values.find(f => f.name === "period").value;
      let executor = message.package.value.values.find(f => f.name === "executor").value;
      let rating = message.package.value.values.find(f => f.name === "rating").value;

      if (period !== "") {
        this.period = period;
        this.executor =executor === null ? 0 : executor === "" ? 0 : executor.value;
        this.rating = rating === null ? 0 : rating === "" ? 0 : rating.value;
      }
    },
    renderTable: function() {
      if (this.period) {
        if (this.active) {
          let msg = {
            name: "SetFilterPanelState",
            package: {
              value: false
            }
          };
          this.messageService.publish(msg);
          this.config.query.parameterValues = [
            { key: "@DateCalc", value: this.period },
            { key: "@RDAId", value: this.executor },
            { key: "@RatingId", value: this.rating }
          ];
          this.loadData(this.afterLoadDataHandler);
        }
      }
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
