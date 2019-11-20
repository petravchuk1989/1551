(function () {
  return {
    init: function() {
      this.districts = [
        { id: 0, name: 'Голосіївська РДА'},
        { id: 1, name: 'Дарницька РДА'},
        { id: 2, name: 'Деснянська РДА'},
        { id: 3, name: 'Дніпровська РДА'},
        { id: 4, name: 'Оболонська РДА'},
        { id: 5, name: 'Печерська РДА'},
        { id: 6, name: 'Подільська  РДА'},
        { id: 7, name: 'Святошинська РДА'},
        { id: 8, name: 'Солом`янська РДА'},
        { id: 9, name: 'Шевченківська РДА'}
      ];
      this.sub = this.messageService.subscribe('GlobalFilterChanged', this.getFiltersParams, this);
    },
    getFiltersParams: function(message){
      const period = message.package.value.values.find(f => f.name === 'period').value;
      const executor = message.package.value.values.find(f => f.name === 'executor').value;
      const rating = message.package.value.values.find(f => f.name === 'rating').value;
      
      if( period !== '' ){
          const periodValue = this.convertDateTimeToDate(period);
          const executorValue = executor === null ? 0 :  executor === '' ? 0 : executor.value;
          const ratingValue = rating === null ? 0 :  rating === '' ? 0 : rating.value;
          const name = 'FilterParameters';
          const parameters = [
            {key: '@DateCalc' , value:  periodValue },
            {key: '@RDAId', value: executorValue },  
            {key: '@RatingId', value: ratingValue } 
          ];
          if(this.rating !== 0) {
              this.messageService.publish({ name, parameters, districts: this.districts, period: periodValue, executor: executorValue, rating: ratingValue});
          }
      }
    },
    convertDateTimeToDate: function(value){
      let date = new Date(value);
      let dd = date.getDate().toString();
      let MM = (date.getMonth() + 1).toString();
      let yyyy = date.getFullYear();
      dd = dd.length === 1 ? '0' + dd : dd;
      MM = MM.length === 1 ? '0' + MM : MM;
      return yyyy + '.' + MM + '.' + dd;
    }, 
    destroy: function () {
      this.sub.unsubscribe();
    }
};
}());
