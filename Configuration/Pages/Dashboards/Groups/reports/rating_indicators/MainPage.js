(function () {
  return { 
    init: function() {
      this.sub = this.messageService.subscribe( 'GlobalFilterChanged', this.getFiltersParams, this );
    },
    getFiltersParams: function(message){
      const dateFilter = message.package.value.values.find(f => f.name === 'period').value;
      const executorFilter = message.package.value.values.find(f => f.name === 'executor').value;
      const ratingFilter = message.package.value.values.find(f => f.name === 'rating').value;
      const name = 'FiltersParams';
      const date = this.changeDateTimeValues(dateFilter);
      if( date !== '' ){
        const executor = executorFilter === null ? 0 :  executorFilter === '' ? 0 : executorFilter.value;
        const rating = ratingFilter === null ? 0 :  ratingFilter === '' ? 0 : ratingFilter.value;
        this.messageService.publish({ name, date, executor, rating  });
      }
    },
    changeDateTimeValues: function(value){
      
        if( value === '') {
          return value;
        }
        let date = new Date(value);
        let dd = date.getDate();
        let MM = date.getMonth() + 1;
        let yyyy = date.getFullYear();
        let HH = date.getUTCHours()
        let mm = date.getMinutes();
        if( (dd.toString()).length === 1){  dd = '0' + dd; }
        if( (MM.toString()).length === 1){ MM = '0' + MM; }
        if( (HH.toString()).length === 1){  HH = '0' + HH; }
        if( (mm.toString()).length === 1){ mm = '0' + mm; }
        let trueDate = yyyy + '-' + MM + '-' + dd;
        return trueDate;
    },
    destroy: function () {
      this.sub.unsubscribe();
    }
  };
}());
