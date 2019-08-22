(function () {
  return {
    title: ' ',
    hint: '',
    formatTitle: function() {},
    customConfig:
                `
                
                <style>
                #container{
                    margin: 30px 30px 20px;                  
                }
                .tableContainer{
                    display: flex;
                    flex-direction: row;
                }
                .tab_title{
                    text-transform: uppercase;
                }
                #filtersWrapper{
                    display: flex;
                    flex-direction: row;
                    justify-content: space-between;
                    padding: 20px 0 10px 0;
                }
                .columnHeader{
                    background-position-x: -93px;
                    position: absolute;
                    width: 180px;
                    height: 46px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    background-repeat: no-repeat;
                    font-weight: 400;
                    font-style: normal;
                    font-size: 16px;
                    color: #FFFFFF;
                    cursor: pointer;
                }
                .columnsWrapper{
                    margin-top: 65px;
                }
                .columnCategorie{
                    border-width: 0px;
                    background: inherit;
                    background-color: rgba(255, 255, 255, 1);
                    box-sizing: border-box;
                    border-width: 1px;
                    border-style: solid;
                    border-color: rgba(228, 228, 228, 1);
                    border-radius: 3px;
                    box-shadow: 0px 1px 3px rgba(0, 0, 0, 0.247058823529412);
                    font-size: 12px;   
                    display: flex;
                    align-items: center;
                    justify-content: center;  
                    cursor: pointer;
                    height: 46px;
                    width: 150px;
                    margin: 5px 0;
                }
                .columnCategorie__title{
                    margin-right: 5px;
                }
                .columnCategorie__yellow{
                    margin: 65px 16px 0 3px;
                }
                .column{
                    position: absolute;
                }
                .column_2{
                    z-index: 180;
                    left: 30px;
                }
                .column_3{
                    z-index: 170;
                    left: 183px;
                }
                .column_4{
                    z-index: 160;
                    left: 345px; 
                }
                .column_5{
                    z-index: 150;
                    left: 507px;
                }
                .column_6{
                    z-index: 140;
                    left: 667px;
                }
                .column_7{
                    z-index: 130;
                    left: 821px;
                }
                .column_8{
                    z-index: 120;
                    left: 983px;
                }
                .column_9{
                    z-index: 110;
                    left: 1144px;
                    height: 42px!important;
                }
                #tabsWrapper{
                    border-bottom: 1px solid rgba(204 204 204);                    
                }
                .tabsContainer{
                    display: flex;
                }
                .tab{
                    color: #15BDF4; 
                    font-weight: 400;
                    font-style: normal;
                    font-size: 14px; 
                    cursor: pointer;
                    padding: 0 20px 6px;
                }
                .tabHover{
                    border-bottom: 3px solid #15BDF4;         
                }
                
                #filtersContainer{
                    display: flex;
                }
                .filter{
                    cursor: pointer;
                    max-width: 300px;
                    display: flex;
                    justify-content: space-between;
                    height: 34px;
                    font-size: 12px;
                    border-width: 0px;
                    color: rgba(0, 0, 0, 0.537254901960784);
                    border-radius: 16px;
                    display: flex;
                    align-items: center;  
                    background-color: rgba(239, 247, 249, 1); 
                    margin: 0 10px;
                }
                .filterIcon{
                    width: 31px;
                    height: 31px;
                    background-color: #fff;
                    border-radius: 50%;
                    margin-left: 2px;
                    color: rgb(132, 220, 249);
                    display: flex;
                    justify-content: center;
                    align-items: center;                    
                }
                .filterTitle{
                    margin: 0 10px 0 25px;
                    font-weight: 400;
                    font-style: normal;
                    font-size: 12px;
                    color: #333333;
                    text-align: center;
                    line-height: normal;                    
                }
                .searchContainer__input{
                    height: 34px;
                    width: 220px;
                    padding: 5px;
                    outline-style: none;
                }
                #header1{
                    z-index: 100;
                }
                </style>
                    <div id = 'container'></div>
                
                `
    ,
    init: function() {
        const header = document.getElementById('header1');
        header.firstElementChild.style.overflow = 'visible';
        header.firstElementChild.firstElementChild.firstElementChild.style.overflow = 'visible';
        
        this.messageService.subscribe('reloadMainTable', this.reloadMainTable, this);
        if(window.location.search == ''){
            let executeQuery = {
                queryCode: 'organization_name',
                parameterValues: [],
                limit: -1
            };
            this.queryExecutor(executeQuery, this.userOrganization, this);
            // 2.1. если нет то дергаешь запрос (получаешь знач в коллбекфанк "ОрганизацияТекущегоЮзера") и заприсываешь её в глоьб переменную + создвешь параметр урл
            
        }else{
            // 2.2 если есть значе заприсываешь её в глоб переменную ГлобПекременнаяОрганизации 
            var getUrlParams = window
                            .location
                                .search
                                    .replace('?', '')
                                        .split('&')
                                            .reduce(function(p, e) {
                                                      var a = e.split('=');
                                                      p[decodeURIComponent(a[0])] = decodeURIComponent(a[1]);
                                                      return p;
                                                    }, {}
                                                        );
            let tabInd = Number(getUrlParams.id);
            this.organizationId = [];
            this.organizationId = (tabInd);
            console.log(this.organizationId);
            let executeQueryValues = {
                queryCode: 'table2',
                limit: -1,
                parameterValues: [ { key: '@organization_id',  value: this.organizationId} ]
            };
            this.queryExecutor(executeQueryValues, this.createTable.bind(this, false, null), this);
            let executeQuery = {
                queryCode: 'organization_name',
                parameterValues: [{ key: '@organizationId',  value: this.organizationId}],
                limit: -1
            };
            this.queryExecutor(executeQuery, this.userOrganization, this);
        }
    },
    userOrganization: function(data){
        let indexOfTypeName = data.columns.findIndex(el => el.code.toLowerCase() === 'organizationname' );
        let indexOfTypeId = data.columns.findIndex(el => el.code.toLowerCase() === 'organizationid' );
        let indexOfTypeDistribute = data.columns.findIndex(el => el.code.toLowerCase() === 'distribute' );
        this.organizationId = [];
        this.organizationId = (data.rows[0].values[indexOfTypeId]);
        this.distribute = (data.rows[0].values[indexOfTypeDistribute]);
        console.log(this.distribute)
        
        this.messageService.publish({name: 'messageWithOrganizationId', value: this.organizationId, distribute:  this.distribute});
        // this.sendOrgId('sendOrgId', this.organizationId);
        document.getElementById('organizationName').value = (data.rows[0].values[indexOfTypeId]);
        document.getElementById('organizationName').innerText = (data.rows[0].values[indexOfTypeName]);
        if( window.location.search != '?id='+data.rows[0].values[indexOfTypeId]+''){
            window.location.search = 'id='+data.rows[0].values[indexOfTypeId]+'';
        }
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
    afterViewInit: function(){
        const container = document.getElementById('container')
        
        const tabsWrapper = this.createElement('div', { id: 'tabsWrapper', className: 'tabsWrapper'});
        const filtersWrapper = this.createElement('div', { id: 'filtersWrapper', className: 'filtersWrapper'});
        const tableContainer = this.createElement('div', { id: 'tableContainer', className: 'tableContainer'});
        const tableWrapper = this.createElement('div', { id: 'tableWrapper', className: 'tableWrapper'}, tableContainer);

        container.appendChild(tabsWrapper);
        container.appendChild(filtersWrapper);
        container.appendChild(tableWrapper);
        this.createTabs();
        this.createFilters();
    },
    createTabs: function(){
        
        let tabFinder__title  = this.createElement('div', { className: ' tab_title', innerText: 'Розширений пошук'});
        let tabInformation__title  = this.createElement('div', { className: 'tabInformation tab_title', innerText: 'ЗАГАЛЬНА ІНФОРМАЦІЯ'});
        let tabAction__title  = this.createElement('div', { className: 'tabAction tab_title', innerText: 'ЗАХІД'});
        let tabProcessingOrders__title  = this.createElement('div', { className: 'tabProcessingOrders tab_title', innerText: 'ОБРОБКА ДОРУЧЕНЬ'});
        let tabOrganizations__title  = this.createElement('div', { className: 'tabOrganizations tab_title', innerText: 'ОРГАНІЗАЦІЇ'});
        
        const tabFinder = this.createElement('div', { id: 'tabFinder', url: 'poshuk_table', className: 'tabFinder tab'}, tabFinder__title);
        const tabInformation = this.createElement('div', { id: 'tabInformation', url: '', className: 'tabInformation tab'}, tabInformation__title);
        const tabAction = this.createElement('div', { id: 'tabAction', url: 'performer_new_actions', className: 'tabAction tab'}, tabAction__title);
        const tabProcessingOrders = this.createElement('div', { id: 'tabProcessingOrders', url: 'performer_new_processing_assigments', className: 'tabHover tabProcessingOrders tab'}, tabProcessingOrders__title);
        const tabOrganizations = this.createElement('div', { id: 'tabOrganizations', url: 'performer_new_organizations', className: 'tabOrganizations tab'}, tabOrganizations__title);
        
        
        const tabsContainer = this.createElement('div', { id: 'tabsContainer', className: 'tabsContainer'}, tabInformation, tabAction, tabProcessingOrders, tabOrganizations, tabFinder);
        tabsWrapper.appendChild(tabsContainer);
 
        let tabs = document.querySelectorAll('.tab');
        tabs.forEach( function (el){
            el.addEventListener( 'click', event => {
                let target =  event.currentTarget;
                this.goToDashboard(target.url);
            })    
        }.bind(this));
    },
    createFilters: function(){
        const searchContainer__input = this.createElement('input', {id: 'searchContainer__input', type: 'search', placeholder: 'Пошук доручення за номером', className: "searchContainer__input"});
        const searchContainer = this.createElement('div', {id: 'searchContainer', className: "searchContainer"}, searchContainer__input);
        
        searchContainer__input.addEventListener('input', event =>  {
            if(searchContainer__input.value.length == 0 ){
                this.resultSearch('clearInput', 0);
                this.showTable(searchContainer__input);
            }
        });
        searchContainer__input.addEventListener('keypress', function (e) {
            var key = e.which || e.keyCode;
            if (key === 13) {
                this.resultSearch('resultSearch', searchContainer__input.value, this.organizationId);
                this.resultSearch('clickOnTable2', 'none');
                this.hideAllItems(0);
            }
        }.bind(this));
        
        const filterLeft__icon = this.createElement('div', { className: "filterLeft__icon filterIcon material-icons", innerText: 'filter_list'});
        const filterLeft__title = this.createElement('div', { className: "filterLeft__title filterTitle",  innerText: 'Голосіївський - Житлове господарство'});
        
        const filterRight__icon = this.createElement('div', { className: "filterLeft filterIcon material-icons", innerText: 'filter_list'});
        const filterRight__title = this.createElement('div', { className: "filterLeft filterTitle", innerText: 'Святошинський - Ліфти'});
        
        const filterLeft = this.createElement('div', { id: 'filterLeft', className: "filterLeft filter"}, filterLeft__icon, filterLeft__title);
        const filterRight  =  this.createElement('div', { id: 'filterRight', className: "filterRight filter"}, filterRight__icon, filterRight__title);
        
        filtersContainer =  this.createElement('div', { id: 'filtersContainer', className: "filtersContainer"}, filterLeft, filterRight);
        
        const organizationName =  this.createElement('div', { id: 'organizationName', className: "organizationName" });
        // filtersWrapper.appendChild(filtersContainer);
        filtersWrapper.appendChild(organizationName);
        filtersWrapper.appendChild(searchContainer);
    },
    reloadMainTable: function(message){
        this.column = message.column;
        this.navigator = message.navigator;
        let targetId = message.targetId;
        while ( tableContainer.hasChildNodes() ) {
            tableContainer.removeChild( tableContainer.childNodes[0] );
        }   
        let executeQueryValues = {
            queryCode: 'table2',
            limit: -1,
            parameterValues: [ { key: '@organization_id',  value: this.organizationId} ]
        };
        this.queryExecutor(executeQueryValues, this.createTable.bind(this, true, targetId), this);
    },
    createTable: function(reloadTable, targetId, data) {
        for(let i = 2; i < data.columns.length; i ++ ){
            let item = data.columns[i];
            let columnHeader =  this.createElement('div', { id: 'columnHeader_'+i+'', code: ''+item.code+'',  className: 'columnHeader', innerText: ''+item.name+''});
            let columnsWrapper =  this.createElement('div', { id: 'columnsWrapper_'+i+'',  className: 'columnsWrapper'});
            console.log( columnHeader.code, columnHeader.innerText)
            if( i == 2){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_blue.png)";
            }else if( i == 3){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_purple.png)";            
            }else if( i == 4 ){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_red.png)";                
            }else if( i == 5){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_orange.png)";
            }else if( i == 6){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_green.png)";
            }else if( i == 7){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_yellow.png)";
            }else if( i == 8){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_light_green.png)";
            }else if( i == 9){
                columnHeader.style.backgroundColor = 'rgba(73, 155, 199, 1)';
                columnHeader.style.height = '46px';
                columnHeader.style.border = '2px solid #fff';
            }
            let column =  this.createElement('div', { id: 'column_'+i+'', code: ''+item.code+'', className: "column"}, columnHeader, columnsWrapper);
            column.classList.add('column_'+i+'');
            tableContainer.appendChild(column);
        }
        for(let i = 0; i < data.rows.length; i ++  ){
            var elRow = data.rows[i];
            for(let  j = 2; j < elRow.values.length; j ++  ){
                let el = elRow.values[j];
                if( el != 0 ){
                    let columnCategorie__value =  this.createElement('div', { className: 'columnCategorie__value', innerText: '('+el+')'});
                    let columnCategorie__title =  this.createElement('div', { className: 'columnCategorie__title', code: ''+elRow.values[1]+'', innerText: ''+elRow.values[1]+''});
                    let columnCategorie =  this.createElement('div', { className: 'columnCategorie', code: ''+elRow.values[1]+''}, columnCategorie__title, columnCategorie__value);
                    document.getElementById('columnsWrapper_'+j+'').appendChild(columnCategorie);
                }
            }
        }
        
        let headers = document.querySelectorAll('.columnHeader');
        headers.forEach( function(el){
            el.addEventListener( 'click', function(event){
                let target = event.currentTarget;
                searchContainer__input.value = '';
                this.resultSearch('clearInput', 0);
                let categories = document.querySelectorAll('.columnCategorie');
                categories.forEach( el => {
                   el.style.display = 'none'; 
                });
                let navigator = 'Усі';
                let column = this.columnName(target);
                this.showTable(target, column, navigator);
            }.bind(this));
        }.bind(this));
        
        let categories = document.querySelectorAll('.columnCategorie');
        categories.forEach( function(el){
            el.addEventListener( 'click', function(event){
                let target = event.currentTarget;
                let categories = document.querySelectorAll('.columnCategorie');
                categories.forEach( el => {
                   el.style.display = 'none'; 
                });
                let navigator = target.firstElementChild.innerText;
                target = target.parentElement.parentElement.firstElementChild;
                let column = this.columnName(target);
                this.showTable(target, column, navigator);
            }.bind(this));
        }.bind(this));
        
        if( reloadTable == true ){
            let categories = document.querySelectorAll('.columnCategorie');
            categories.forEach( el => {
               el.style.display = 'none'; 
            });            
            let target = document.getElementById(targetId);
            this.showTable(target,  this.column, this.navigator );
        }
    },
    columnName: function(target){
        let column = '';
        if( target.code == 'nadiyshlo'){
            column = 'Надійшло'
        }else if( target.code == 'neVKompetentsii'){
            column = 'Не в компетенції'
        }else if( target.code == 'prostrocheni'){
            column = 'Прострочені'
        }else if( target.code == 'uvaga'){
            column = 'Увага'
        }else if( target.code == 'vroboti'){
            column = 'В роботі'
        }else if( target.code == 'dovidoma'){
            column = 'До відома'
        }else if( target.code == 'naDoopratsiyvanni' ){
            column = 'На доопрацюванні'
        }else if( target.code == 'neVykonNeMozhl'){
            column = 'План/Програма'
        }
        return column
    },
    showTable: function(target, columnName, navigator){
        const headers = document.querySelectorAll('.columnHeader');
        if( target.classList.contains('check') || target.classList.contains('hover') || target.id == 'searchContainer__input'){
            
            document.getElementById('columnHeader_2').style.backgroundImage = "url(assets/img/1551/crm1551_blue.png)";
            document.getElementById('columnHeader_3').style.backgroundImage = "url(assets/img/1551/crm1551_purple.png)"; 
            document.getElementById('columnHeader_4').style.backgroundImage = "url(assets/img/1551/crm1551_red.png)";
            document.getElementById('columnHeader_5').style.backgroundImage = "url(assets/img/1551/crm1551_orange.png)";
            document.getElementById('columnHeader_6').style.backgroundImage = "url(assets/img/1551/crm1551_green.png)";
            document.getElementById('columnHeader_7').style.backgroundImage = "url(assets/img/1551/crm1551_yellow.png)"; 
            document.getElementById('columnHeader_8').style.backgroundImage = "url(assets/img/1551/crm1551_light_green.png)";
            document.getElementById('columnHeader_9').style.backgroundColor = "rgba(73, 155, 199, 1)";
            headers.forEach( function(el) {
                el.classList.remove('hover'); 
                el.classList.remove('check'); 
            }.bind(this));
            this.hideAllItems(1)
            this.sendMesOnBtnClick('clickOnTable2', 'none', 'none');
        }else{
            target.classList.add('hover');
            headers.forEach( function(target, header) {
                let headers = document.querySelectorAll('.columnHeader');
                if( target.id != header.id ){
                    if( header.id == headers[7].id ){
                            headers[7].style.backgroundColor = "#d3d3d3";
                            headers[7].classList.add('check');
                    }else{
                        header.style.backgroundImage = "url(assets/img/1551/crm1551_disable.png)";
                        header.classList.add('check');
                    }
                }  
            }.bind(this, target));
            this.sendMesOnBtnClick('clickOnTable2', columnName, navigator, target.id);
        }
    },
    hideAllItems: function(value){
        var categories = document.querySelectorAll('.columnCategorie');
        if( value == 0){
            categories.forEach( el => {
               el.style.display = 'none'; 
            });                                                            
        }else if( value == 1){
             categories.forEach( el => {
               el.style.display = 'flex'; 
            }); 
        }    
    },
    sendMesOnBtnClick: function(message, column, navigator, targetId ){
        this.messageService.publish( {
            name: message,
            column: column,  
            navigation: navigator, 
            orgId: this.organizationId, 
            orgName: organizationName.innerText,
            targetId:  targetId
        });
    },
    resultSearch: function(message, value, id){
        this.messageService.publish({name: message, value: value, orgId: id });
    },  
    destroy: function() {
     
     
    }    
};
}());
