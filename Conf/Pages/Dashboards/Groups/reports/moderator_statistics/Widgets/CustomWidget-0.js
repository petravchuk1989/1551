(function() {
    return {
        title: 'На модерації > 2 годин',
        hint: '',
        formatTitle: function() {},
        customConfig:
                    ` 
                <div id='container1' class='main-con'>
                </div>
                    `
        ,
        init: function() {
            this.subscribers.push(this.messageService.subscribe('GlobalFilterChanged', this.setFiltersParams, this));
            this.firstLoad = true;
            this.subscribers.push(this.messageService.subscribe('ApplyGlobalFilters', this.resetParams, this));
        },
        createElement: function(tag, props, ...children) {
            const element = document.createElement(tag);
            Object.keys(props).forEach(key => element[key] = props[key]);
            const zeroLength = 0;
            if(children.length > zeroLength) {
                children.forEach(child =>{
                    element.appendChild(child);
                });
            }
            return element;
        },
        setFiltersParams: function(message) {
            const period = message.package.value.values.find(f => f.name === 'period').value;
            const operator = message.package.value.values.find(f => f.name === 'operator').value;
            this.dateFrom = period.dateFrom;
            this.dateTo = period.dateTo;
            if(operator) {
                this.operator = operator.map(elem=>elem.value).join(',');
            } else {
                this.operator = operator
            }
            if(this.firstLoad) {
                this.firstLoad = false;
                this.resetParams()
            }
        },
        changeDateTimeValues: function(value) {
            let date = new Date(value);
            let dd = date.getDate().toString();
            let mm = (date.getMonth() + 1).toString();
            let yyyy = date.getFullYear().toString();
            dd = dd.length === 1 ? '0' + dd : dd;
            mm = mm.length === 1 ? '0' + mm : mm;
            return `${dd}.${mm}.${yyyy}`;
        },
        resetParams: function() {
            let executeQuery = {
                queryCode: 'db_ModStat_Main',
                parameterValues: [
                    {key: '@date_from', value: this.dateFrom},
                    {key: '@date_to', value: this.dateTo},
                    {key: '@user_Ids', value: this.operator}
                ],
                limit: -1
            };
            this.queryExecutor(executeQuery, this.load, this);
        },
        load: function({rows}) {
            const list = document.querySelectorAll('#CustomWidget-0,#CustomWidget-1,#CustomWidget-2,#CustomWidget-3,#CustomWidget-4')
            list.forEach(e=>{
                e.classList.add('cell-item')
            })
            const con = document.getElementById('container1')
            if(con.hasChildNodes()) {
                con.innerHTML = '';
            }
            const grid = `<div class='widget-container'>
                        <p class='widget-value cell-info'>${rows[0].values[1]}</p>
                        </div>`;
            con.insertAdjacentHTML('beforeend',grid)
        }
    };
}());
