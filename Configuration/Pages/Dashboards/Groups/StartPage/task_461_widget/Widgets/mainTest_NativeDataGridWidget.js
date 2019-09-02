(function () {
    return  {
      config: {
          query: {
              code: 'CoordinatorController_table',
              parameterValues: [ ],
              filterColumns: [],
              sortColumns: [],
              skipNotVisibleColumns: true,
              chunkSize: 1000
          },
          columns: [
            {
                dataField: 'navigation',
                caption: '',
                width: 200,
                fixed: true,
            }, {
                dataField: 'neVKompetentsii',
                caption: 'Не в компетенції', 
                width: 50,
                fixed: true,
            }, {
                dataField: 'doopratsiovani',
                caption: 'Доопрацьовані',
                width: 50,
                fixed: true,                
            }, {
                dataField: 'rozyasneno',
                caption: 'Роз`яcнено',
                width: 50,
                fixed: true,                
            }, {
                dataField: 'prostrocheni',
                caption: 'Прострочені',
                width: 50,
                fixed: true,                
            }, {
                dataField: 'neVykonNeMozhl',
                caption: 'Не можливо виконати в даний період',
                width: 50,
                fixed: true,                
            }
            ],
      },
      init: function() {
          this.loadData(this.afterLoadDataHandler);
          this.config.onContentReady = this.afterRenderTable.bind(this);
      },
      afterLoadDataHandler: function(data) {
          this.render();
      },
      afterRenderTable: function(){
          let elements = document.querySelectorAll('.dx-datagrid-export-button');
          elements = Array.from(elements);
          elements.forEach( function(element){
              let spanElement = this.createElement('span', { className: 'dx-button-text', innerText: 'Excel'});
              element.firstElementChild.appendChild(spanElement);
          }.bind(this));
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
      },
  };
  }());
  