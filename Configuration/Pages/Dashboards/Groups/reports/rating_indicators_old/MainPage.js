(function () {
  return { 
    init: function() {
      this.sub = this.messageService.subscribe( 'GlobalFilterChanged', this.getFiltersParams, this );
    },
    getFiltersParams: function(message){
      const date = message.package.value.values.find(f => f.name === 'period').value;
      const executor = message.package.value.values.find(f => f.name === 'executor').value;
      const rating = message.package.value.values.find(f => f.name === 'rating').value;
      const name = 'FiltersParams';
      if( date !== '' ){
        executor = executor === null ? 0 :  executor === '' ? 0 : executor.value;
        rating = rating === null ? 0 :  rating === '' ? 0 : rating.value;
        this.messageService.publish({ name, date, executor, rating  });
      }
    },
    destroy: function () {
      this.sub.unsubscribe();
    }
  };
}());
