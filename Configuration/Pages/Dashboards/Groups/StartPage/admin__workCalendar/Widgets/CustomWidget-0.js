(function () {
  return {
    title: ' ',
    hint: '',
    formatTitle: function() {},
    customConfig:
                `
                <div id='container' ></div>
                `
    ,
    init: function() {
        this.sub = this.messageService.subscribe( 'GlobalFilterChanged', this.getFiltersParams, this );
    },
    getFiltersParams: function(message){
        this.year = message.package.value.values.find(f => f.name === 'FilterYear').value;
        if( this.year !== '' &&   this.year !== null){
            let executeQuery = {
                queryCode: 'workDaysCalendar',
                limit: -1,
                parameterValues: [
                    { key: '@year', value: this.year.viewValue  }    
                ]
            };
            this.queryExecutor(executeQuery, this.load, this);
        }
    },
    load: function(data) {
       
        this.yearCalendar = [];
        for(let i = 0; i < data.rows.length;  i ++ ){
            indexDateCode = data.columns.findIndex(el => el.code.toLowerCase() === 'date' );
            indexId = data.columns.findIndex(el => el.code.toLowerCase() === 'id' );
            let date = new Date( data.rows[i].values[indexDateCode]);
            let year = date.getFullYear();
            let month = date.getMonth();
            let day = date.getDay();
            month += 1;
            let monthLength = getLastDayOfMonth(year, month);
            function getLastDayOfMonth(year, month) {
                let date = new Date(year, month, 0);
                return date.getDate();
            }
            day =  day === 0 ? 7 : day;
            
            let arr = [];
            let len = i + monthLength
            for( t = i; t < len; t++  ){
                let day = data.rows[t];
                arr.push(day.values[indexId]);
            }
            let obj = {
                year,
                month,
                monthLength,
                day,
                arr,
            }
            this.yearCalendar.push(obj);
            i = i + monthLength - 1;
        }
        this.createCalendarWrapper(data);
    },
    createCalendarWrapper: function(data){
        container = document.getElementById('container');
        while (container.hasChildNodes()) {
            container.removeChild(container.childNodes[0]);
        }
        let createNewYearBtn = this.createElement('button', {  id: 'createNewYearBtn', innerText: 'Додати наступний рік' });
        let createNewYearContainer = this.createElement('div', {  id: 'createNewYearContainer' }, createNewYearBtn);
        let yearContainer = this.createElement('div', {  id: 'yearContainer' });
        container.appendChild(createNewYearContainer);
        container.appendChild(yearContainer);

        createNewYearBtn.addEventListener( 'click', event => {
            let executeQuery = {
                queryCode: 'ak_workDaysCalendarAddNewYear',
                limit: -1,
                parameterValues: []
            };
            this.queryExecutor(executeQuery);
        });
        
        this.yearCalendar.forEach( month => {
            var dayBox;
            let monday = this.createElement('div', {  className: 'calenDay', innerText: 'ПН'});
            let tuesday = this.createElement('div', {  className: 'calenDay', innerText: 'ВТ'});
            let wednesday = this.createElement('div', {  className: 'calenDay', innerText: 'СР'});
            let thursday = this.createElement('div', {  className: 'calenDay', innerText: 'ЧТ'});
            let friday = this.createElement('div', {  className: 'calenDay', innerText: 'ПТ'});
            let saterday = this.createElement('div', {  className: 'calenDay', innerText: 'СБ'});
            let sunday = this.createElement('div', {  className: 'calenDay', innerText: 'ВС'});
            let monthBox = this.createElement('div', { id: 'monthBox_'+month.year+'_'+month.month+'', className: 'month'}, monday, tuesday, wednesday, thursday, friday, saterday, sunday);
            for(let i = 0; i < month.day -1 ; i ++){
                dayBox = this.createElement('div', { id: 'day_'+month.year+'_'+month.month+'_00', className: 'calenDay emptyDay'});
                monthBox.appendChild(dayBox);
            }
            for(let i = 0; i < month.monthLength; i ++){
                dayBox = this.createElement('div', { dayId: month.arr[i], id: 'day_'+month.year+'_'+month.month+'_'+(i+1), innerText: i+1,  className: 'calenDay day', isWork: true });
                monthBox.appendChild(dayBox);
            }
            let ml = monthBox.childNodes.length;
            if(  ml < 42  &&  ml > 36){
                let c = 42 - ml; 
                for(let i = 0; i < c; i ++){
                    let dayBox = this.createElement('div', { id: 'day_'+month.year+'_'+month.month+'_00', className: 'calenDay emptyDay'});
                    monthBox.appendChild(dayBox);
                }
            }else if( ml < 49  &&  ml > 42 ){
                let c = 49 - ml; 
                for(let i = 0; i < c; i ++){
                    let dayBox = this.createElement('div', { id: 'day_'+month.year+'_'+month.month+'_00', className: 'calenDay emptyDay'});
                    monthBox.appendChild(dayBox);
                }
            }
            switch(month.month) {
              case 1: 
                var title = 'Січень' 
                break
              case 2: 
                var title = 'Лютий' 
                break
              case 3: 
                var title = 'Березень' 
                break
              case 4: 
                var title = 'Квітень' 
                break
              case 5: 
                var title = 'Травень' 
                break
              case 6: 
                var title = 'Червень' 
                break
              case 7: 
                var title = 'Липень' 
                break
              case 8: 
                var title = 'Серпень' 
                break
              case 9: 
                var title = 'Вересень' 
                break
              case 10: 
                var title = 'Жовтень' 
                break
              case 11: 
                var title = 'Листопад' 
                break
              case 12: 
                var title = 'Грудень' 
                break
            }
            let monthTitle = this.createElement('div', {  className: 'monthTitle', innerText: title});
            let monthWrapper = this.createElement('div', {  className: 'monthWrapper' }, monthTitle, monthBox);
            yearContainer.appendChild(monthWrapper);
        });
        
        var days = document.querySelectorAll('.day');
        days = Array.from(days);
        days.forEach(  day => {
            day.addEventListener( 'dblclick',  event => {
                event.stopImmediatePropagation();
                let target = event.currentTarget;
                let executeQuery = {
                    queryCode: 'ak_workDaysCalendarUpdate',
                    limit: -1,
                    parameterValues: [ { key: '@Id', value: target.dayId} ]
                };
                this.queryExecutor(executeQuery);
                if( target.isWork === true  ){
                    target.isWork = false;
                    target.style.backgroundColor = '#f4b084';
                }else{
                    target.isWork = true;
                    target.style.backgroundColor = '#a9d08e';
                }
            });
        });
        this.setThisYearCalendar(data);
    },
    setThisYearCalendar: function(data){
        data.rows.forEach( day => {
            dateCode = data.columns.findIndex(el => el.code.toLowerCase() === 'date' );
            isWorkCode = data.columns.findIndex(el => el.code.toLowerCase() === 'is_work' );
            var fullDay = new Date( day.values[dateCode] );
            var year = fullDay.getFullYear();
            var month = fullDay.getMonth();
            var date = fullDay.getDate();
            month = month + 1;
            var cellDay = document.getElementById('day_'+year+'_'+month+'_'+date+'');
            if( day.values[isWorkCode] === false ){
                cellDay.isWork = false;
                cellDay.style.backgroundColor = '#f4b084';
            }else{
                cellDay.isWork = true;
                cellDay.style.backgroundColor = '#a9d08e';
            }
        });
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
        this.sub.unsubscribe();
    },
};
}());
