(function() {
    return {
        title: ' ',
        hint: '',
        formatTitle: function() {},
        customConfig:
                    `
                    <style>
                        #container{}
                        #tabsWrapper{
                          display: flex;
                          justify-content: space-around;
                          display: flex;
                          justify-content: space-between;
                          margin-right: 10px;
                          max-width: 900px;
                          margin: 10px auto;
                          border-bottom: 1px solid rgba(204 204 204);
                        }
                        .tab{
                          text-transform: uppercase;
                          color: #15BDF4;
                          font-weight: 400;
                          font-style: normal;
                          font-size: 14px;
                          cursor: pointer;
                          padding: 0 20px 6px;
                        }
                        .tabHover {
                          border-bottom: 3px solid #15BDF4;
                        }  
                    </style>
                    <div id='container'></div> 
                    `
        ,
        init: function() {
            this.results = [];       
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
            this.sub = this.messageService.subscribe('getConfig', this.executeQuery, this);
        },
        currentTab: 'tabSpeedDone',
        afterViewInit: function() {
            const CONTAINER = document.getElementById('container');
            const tabSpeedDone = this.createElement('div',
                {
                    id: 'tabSpeedDone',
                    className: 'tab tabHover',
                    innerText: 'Швидкість виконання'
                }
            );
            const tabSpeedExplained = this.createElement('div',
                {
                    id: 'tabSpeedExplained',
                    className: 'tab',
                    innerText: 'Швидкість роз\'яснення'
                }
            );
            const tabFactDone = this.createElement('div', 
                { 
                    id: 'tabFactDone', 
                    className: 'tab', 
                    innerText: 'Фактичне виконання'
                }
            );

            const tabsWrapper = this.createElement('div', { id: 'tabsWrapper'}, tabSpeedDone, tabSpeedExplained, tabFactDone);
            CONTAINER.appendChild(tabsWrapper);
            const tabs = document.querySelectorAll('.tab');
            tabs.forEach(tab => {
                tab.addEventListener('click', e => {
                    tabs.forEach(tab => tab.classList.remove('tabHover'));
                    let target = e.currentTarget;
                    target.classList.add('tabHover');
                    this.currentTab = target.id;
                    this.messageService.publish({name: 'showTable', tabName: target.id});
                });
            });
        },
        createElement: function(tag, props, ...children) {
            const element = document.createElement(tag);
            Object.keys(props).forEach(key => element[key] = props[key]);
            if(children.length > 0) {
                children.forEach(child =>{
                    element.appendChild(child);
                });
            } return element;
        },
        executeQuery: function(message) {
            this.results = [];            
            this.results_tab1 = [];
            this.results_tab2 = [];
            this.results_tab3 = [];
            const tab = message.tab;
            const codeResult = message.codeResult;
            const config = message.config;
            config.columns = [];
            config.summary.totalItems = [];
            config.query.parameterValues = message.parameters;
            let executeQuery = {
                queryCode: config.query.code,
                parameterValues: config.query.parameterValues,
                limit: -1
            };
            this.queryExecutor(executeQuery, this.setColumns.bind(this, config, codeResult, tab), this);
            this.showPreloader = false;
        },
        setColumns: function(config, codeResult, tab, data) {
            if(data.rows.length) {
                for (let i = 0; i < data.columns.length; i++) {
                    const element = data.columns[i];
                    if(element.code !== 'QuestionTypeId') {
                        let format = undefined;
                        const width = i === 1 ? 400 : 120;
                        const dataField = element.code;
                        const caption = this.setCaption(element.name);
                        const columnSliced = element.name.slice(0, 7);
                        if(columnSliced === 'Percent') {
                            format = function(value) {
                                return value.toFixed(2);
                            }
                        }
                        const obj = { dataField, caption, width, format }
                        config.columns.push(obj);
                    }
                }
                config.keyExpr = data.columns[0].code;
                config.columns[0].fixed = true;
                let executeQuery = {
                    queryCode: codeResult,
                    parameterValues: config.query.parameterValues,
                    limit: -1
                };
                this.queryExecutor(executeQuery, this.setColumnsSummary.bind(this, config, tab), this);
                this.showPreloader = false;
            } else {
                this.hidePagePreloader('Зачекайте, завантажуються фiльтри');
            }
        },
        setCaption: function(caption) {
            if(caption === 'QuestionTypeName') {
                return '';
            } else if(caption === 'EtalonDays') {
                return 'Середнє (еталон)';
            }
            const id = Number(caption.slice(-1));
            const index = this.districts.findIndex(el => el.id === id);
            return this.districts[index].name;
        },
        setColumnsSummary: function(config, tab, data) {
            this.results = [];
            if(data.rows.length) {
                for (let i = 0; i < data.columns.length; i++) {
                    const element = data.columns[i];
                    const dataField = 'Place_' + element.code;
                    const value = data.rows[0].values[i];
                    let objAvg = {
                        column: dataField,
                        summaryType: 'avg',
                        customizeText: function(data) {
                            return data.value.toFixed(2);
                        }
                    }
                    // let objAvg = {
                    //     column: dataField,
                    //     name: dataField+'_1',
                    //     summaryType: 'custom'
                    // }
                   
                    let obj = {
                        column: dataField,
                        name: dataField,
                        summaryType: 'custom'
                    }
                    
                    this.results.push(value);
                    config.summary.totalItems.push(objAvg);
                    config.summary.totalItems.push(obj);
                }
                
                const name = 'setConfig' + tab;
                this.messageService.publish({ 
                    name, 
                    config, 
                    results: this.results});
                this.hidePagePreloader('Зачекайте, завантажуються фiльтри');
            } else {
                this.hidePagePreloader('Зачекайте, завантажуються фiльтри');
            }
        },
        destroy: function() {
            this.sub.unsubscribe();
        }
    };
}());
