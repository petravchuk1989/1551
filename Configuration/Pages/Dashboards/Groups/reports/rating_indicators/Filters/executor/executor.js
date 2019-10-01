(function () {
    return {
      placeholder: 'Виконавець',
      keyValue: 'Id',
      displayValue: 'Name',
      baseQueryOptions: {
          queryCode: 'ak_Filter_ConstructorOrganizationGroups',
          filterColumns: null,
          limit: -1,
          parameterValues: [],
          pageNumber: 1,
          sortColumns: [
              {
              key: 'Id',
              value: 0
              }
          ]
      },
      onItemSelect: function(item) {
          this.setValues(item);
      },
      onClearFilter: function() {
      },
      initValue: function() {
        this.setDefaultValue('first'); 
      }, 
      setValues: function(item) {
          let message = {
              name: '',
              package: {
                  type: item.value
              }
          }
          this.messageService.publish(message);
      }
  };
  }());
  