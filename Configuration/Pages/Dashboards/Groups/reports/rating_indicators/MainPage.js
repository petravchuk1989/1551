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
      const date = dateFilter;
      if( date !== '' ){
        const executor = executorFilter === null ? 0 :  executorFilter === '' ? 0 : executorFilter.value;
        const rating = ratingFilter === null ? 0 :  ratingFilter === '' ? 0 : ratingFilter.value;
        this.messageService.publish({ name, date, executor, rating  });
      }
    },
    destroy: function () {
      this.sub.unsubscribe();
    }
  };
}());
