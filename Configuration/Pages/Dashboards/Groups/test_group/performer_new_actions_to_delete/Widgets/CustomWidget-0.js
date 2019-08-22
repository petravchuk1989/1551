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
                    flex-direction: column;
                }
                .columnWrapper{
                    position: relative;
                }
                #organizationName{
                    font-size: 18px;
                    font-weight: 600;
                }
                #filtersWrapper{
                    display: flex;
                    flex-direction: row;
                    justify-content: space-between;
                    padding: 20px 0 10px;
                }
                .columnHeader{
                    width: 268px;
                    height: 46px;
                    display: flex;
                    align-items: center;
                    justify-content: center;     
                    background-repeat: no-repeat;
                    font-family: 'Roboto';
                    font-weight: 400;
                    font-style: normal;
                    font-size: 16px;
                    color: #fff;
                    background-size: 100%;
                    cursor: pointer;
                }
                .columnCategorie{
                    border-width: 0px;
                    height: 46px;
                    background: inherit;
                    background-color: rgba(255, 255, 255, 1);
                    box-sizing: border-box;
                    border-width: 1px;
                    border-style: solid;
                    border-color: rgba(228, 228, 228, 1);
                    border-radius: 3px;
                    -moz-box-shadow: 0px 1px 3px rgba(0, 0, 0, 0.247058823529412);
                    -webkit-box-shadow: 0px 1px 3px rgba(0, 0, 0, 0.247058823529412);
                    box-shadow: 0px 1px 3px rgba(0, 0, 0, 0.247058823529412);
                    font-size: 14px;   
                    display: flex;
                    align-items: center;
                    justify-content: center;  
                    margin: 10px 10px 0 16px;
                    cursor: pointer;
                }
                .columnCategorie__title{
                    margin-right: 5px;
                }
                .columnCategorie__yellow{
                    margin: 10px 16px 0 3px;
                }
                .column{
                    position: absolute;
                }
                .column_2{
                    z-index: 50;
                    left: 30px;
                }
                .column_3{
                    z-index: 40;
                    left: 276px;
                }
                .column_4{
                    z-index: 30;
                    left: 528px; 
                }
                .column_5{
                    z-index: 20;
                    left: 780px;
                }
                .column_6{
                    left: 1034px;
                    height: 42px!important;
                }
                #tabsWrapper{
                    border-bottom: 1px solid rgba(204 204 204);                    
                }
                #eventWrapper{
                    flex-direction: column;
                }
                .tabsContainer{
                    display: flex;
                }
                .tab{
                    color: #15BDF4; 
                    font-family: 'Roboto';
                    font-weight: 400;
                    font-style: normal;
                    font-size: 14px; 
                    cursor: pointer;
                    padding: 0 20px 6px;
                }
                .tabHover{
                    border-bottom: 3px solid #15BDF4;         
                }
                .event{
                    height: 100%;
                    background-color: rgba(240, 240, 240, 1);
                    margin: 3px 0;
                }
                .orgElements{
                    flex-direction: column;
                }
                .eventTitle {
                    min-width: 200px;
                    padding: 10px;
                }
                .eventTitle __icon{
                    cursor: pointer;
                    margin: 0 7px;
                    display: flex;
                    align-items: center;                    
                }
                .eventTitle __name{
                    margin: 4px;
                    display: flex;
                    align-items: center;                    
                }
                .counter{
                    height: 50px;
                    width: 243px;
                    background-color: #fff;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    flex-direction: row;
                    margin: 5px 12px 5px 4px;  
                    cursor: pointer;
                }
                .counterBorder{
                    box-shadow: 0px 1px 3px rgba(0, 0, 0, 0.247058823529412);
                    box-sizing: border-box;
                    border-width: 1px;
                    border-style: solid;
                    border-color: rgba(228, 228, 228, 1);
                    border-radius: 3px;    
                }
                .refItem__value{
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100%;
                }
                .referalColumn{
                    height: 100%;
                    align-items: center;
                    justify-content: center;                    
                    flex-direction: column;
                }
                .referalItem{
                    margin: 5px;
                }
                .emptyBox{
                    width: 100px;
                    margin: 5px;
                }                
                #eventsHeader{
                    margin: 16px 0 9px;                   
                }
                #headerTitle{
                    width: 203px;
                }
                
                .headerItems{
                    position: relative;
                    height: 46px;
                    cursor: pointer;
                }
                .headerItem{
                    font-family: 'Roboto';
                    font-weight: 400;
                    font-style: normal;
                    font-size: 16px;
                    color: #FFFFFF;
                    background-repeat: no-repeat;
                    position: absolute;
                    width: 270px;
                    height: 100%;
                    align-items: center;
                    justify-content: center;                    
                } 
                .overdue{
                    z-index: 30;
                }
                .notActive{
                    z-index: 20;
                    left: 252px;
                }
                .inWork{
                    z-index: 10;
                    left: 500px;
                }
                .displayNone{
                    display: none;                    
                }
                .displayFlex{
                    display: flex;
                }
                </style>
                    <div id = 'container'></div>
                `
    ,
    init: function() {
        const header1 = document.getElementById('header1');
        header1.firstElementChild.style.overflow = 'visible';
        header1.firstElementChild.firstElementChild.firstElementChild.style.overflow = 'visible';
        if(window.location.search == ''){
            let executeQuery = {
                queryCode: 'organization_name',
                parameterValues: [],
                limit: -1
            };
            this.queryExecutor(executeQuery, this.userOrganization, this);
            
        }else{
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
            let executeQuery = {
                queryCode: 'organization_name',
                parameterValues: [{ key: '@organizationId',  value: this.organizationId}],
                limit: -1
            };
            this.queryExecutor(executeQuery, this.userOrganization, this);
        }
        
        let executeQueryOrganizations = {
            queryCode: 'events',
            limit: -1,
            parameterValues: [ 
                    { key: '@organization_id', value: this.organizationId }
                ]
        };
        this.queryExecutor(executeQueryOrganizations, this.createSubordinateOrganizationsTable, this);
        
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
        const tableContainer = this.createElement('div', { id: 'tableContainer', className: 'tableContainer'});
        const tableWrapper = this.createElement('div', { id: 'tableWrapper', className: 'tableWrapper'}, tableContainer);
        
        container.appendChild(tabsWrapper);
        container.appendChild(tableContainer);
        this.createTabs();
    },
    createTabs: function(){
        
        let tabInformation__title  = this.createElement('div', { className: 'tabInformation tab_title', innerText: 'ЗАГАЛЬНА ІНФОРМАЦІЯ'});
        let tabAction__title  = this.createElement('div', { className: 'tabAction tab_title', innerText: 'ЗАХІД'});
        let tabProcessingOrders__title  = this.createElement('div', { className: 'tabProcessingOrders tab_title', innerText: 'ОБРОБКА ДОРУЧЕНЬ'});
        let tabOrganizations__title  = this.createElement('div', { className: 'tabOrganizations tab_title', innerText: 'ОРГАНІЗАЦІЇ'});
        
        
        const tabInformation = this.createElement('div', { id: 'tabInformation', url: '', className: 'tabInformation tab'}, tabInformation__title);
        const tabAction = this.createElement('div', { id: 'tabAction', url: 'performer_new_actions', className: 'tabHover tabAction tab'}, tabAction__title);
        const tabProcessingOrders = this.createElement('div', { id: 'tabProcessingOrders', url: 'performer_new_processing_assigments', className: 'tabProcessingOrders tab'}, tabProcessingOrders__title);
        const tabOrganizations = this.createElement('div', { id: 'tabOrganizations', url: 'performer_new_organizations', className: 'tabOrganizations tab '}, tabOrganizations__title);
        
        
        const tabsContainer = this.createElement('div', { id: 'tabsContainer', className: 'tabsContainer'}, tabInformation, tabAction, tabProcessingOrders, tabOrganizations);
        tabsWrapper.appendChild(tabsContainer);
 
        let tabs = document.querySelectorAll('.tab');
        tabs.forEach( function (el){
            el.addEventListener( 'click', event => {
                let target =  event.currentTarget;
                this.goToDashboard(target.url);
            })    
        }.bind(this));
    },
    sendMesOnBtnClick: function(message, typeEvent, source, orgId){
        this.messageService.publish({name: message, typeEvent: typeEvent,  source: source, orgId: orgId });
    },
    showTable: function(target, headers, typeEvent, source){
        if( target.classList.contains('check') || target.classList.contains('hover')){
            document.getElementById('headerItem__overdue').style.backgroundImage = "url(assets/img/1551/crm1551_blue.png)";
            document.getElementById('headerItem__notActive').style.backgroundImage = "url(assets/img/1551/crm1551_green.png)";
            document.getElementById('headerItem__inWork').style.backgroundColor = 'rgba(173, 118, 205, 1)';

            document.getElementById('eventWrapper').classList.remove('displayNone');
            document.getElementById('eventWrapper').classList.add('displayFlex');
            headers.forEach( function(el) {
                el.classList.remove('check'); 
                el.classList.remove('hover');
            }.bind(this));
            this.sendMesOnBtnClick('showEventTable', 'none', 'none');
        }else{
            target.classList.add('hover');
            document.getElementById('eventWrapper').classList.add('displayNone');
            document.getElementById('eventWrapper').classList.remove('displayFlex');
            headers.forEach( function(target, header) {
                let headers = document.querySelectorAll('.headerItem');
                if( target.id != header.id ){
                    if( header.id == headers[2].id ){
                            headers[2].classList.add('check');
                            headers[2].style.backgroundColor = "#d3d3d3";
                            headers[2].style.marginTop = '2px';
                            headers[2].style.height = '42px';
                    }else{
                        header.style.backgroundImage = "url(assets/img/1551/crm1551_disable.png)"
                        header.classList.add('check');
                    }
                }  
            }.bind(this, target));
            this.sendMesOnBtnClick('showEventTable', typeEvent, source, this.organizationId);
        }
    },
    createSubordinateOrganizationsTable: function(data){
        this.createHeaderOrganizations();
        for ( let i = 0; i < data.rows.length; i ++){
            var row = data.rows[i];
            
            var eventElementsСounter = this.createElement('div', {  className: 'eventElementsСounter displayFlex'});    
            var eventElements = this.createElement('div', {  className: 'orgElements displayFlex'}, eventElementsСounter);
             
            var eventTitle__name = this.createElement('div', {  className: 'eventTitle__name', innerText: ''+row.values[1]+''});
            var eventTitle = this.createElement('div', {  className: 'eventTitle displayFlex'}, eventTitle__name);
            var event = this.createElement('div', {  className: 'event displayFlex', id: ''+row.values[0]+''}, eventTitle, eventElements);
            eventWrapper.appendChild(event);
            var name = row.values[1];
            for ( let i = 2;  i <row.values.length; i ++){
                let el = row.values[i];
                if( i == 2 ){
                    var link = 'Прострочені';
                }else if ( i == 3){
                    var link = 'Не активні';
                }else if( i == 4 ){
                    var link = 'В роботі';
                }
                if( el != '0 (0)'){
                    var eventElementsСounterItem__value = this.createElement('div', {  className: ' counter_value', innerText: ''+el+''});
                    var eventElementsСounterItem = this.createElement('div', { value: link,  name: name,  className: 'counter'},eventElementsСounterItem__value);
                }else{
                    var eventElementsСounterItem = this.createElement('div', {  className: 'counter'});
                }
                console.log(eventElementsСounterItem.value, eventElementsСounterItem.name);
                eventElementsСounter.appendChild(eventElementsСounterItem);
            }
        }    
        let counterHeaderElements = document.querySelectorAll('.counter');
        counterHeaderElements.forEach( el => {
            if(el.childNodes.length == 0 ){
                el.style.backgroundColor = 'transparent';
            }else{
                el.classList.add('counterBorder');
            }
        });
        
        let headers = document.querySelectorAll('.headerItem ');
        headers.forEach( function(el){
            el.addEventListener( 'click', function(event){
                
                let target = event.currentTarget;
                let headers = document.querySelectorAll('.headerItem');
                let source = 'Усі';
                let typeEvent = target.innerText;
                this.showTable(target, headers, typeEvent, source);
            }.bind(this));
        }.bind(this));
        
        let counters = document.querySelectorAll('.counter');
        counters.forEach( function(el){
            el.addEventListener( 'click', function(event){
                let target = event.currentTarget;
                let headers = document.querySelectorAll('.headerItem');
                let source = target.name;
                let typeEvent = target.value;
                target = target.parentElement.firstElementChild;
                if( typeEvent == 'Прострочені'){
                    target  = document.getElementById('headerItem__overdue');
                }else if( typeEvent == 'Не активні' ){
                    target  = document.getElementById('headerItem__notActive');
                }else if(typeEvent == 'В роботі'  ){
                    target  = document.getElementById('headerItem__inWork');
                }
                this.showTable(target, headers, typeEvent, source);
            }.bind(this));
        }.bind(this));
        
    },
    createHeaderOrganizations: function(){
        const headerItem__overdue    = this.createElement('div', { id: 'headerItem__overdue', value: 'Прострочені', className: 'headerItem overdue displayFlex', innerText: 'Прострочені'});
        const headerItem__notActive  = this.createElement('div', { id: 'headerItem__notActive', value: 'Не активні', className: 'headerItem notActive displayFlex', innerText: 'Не активні'});
        const headerItem__inWork     = this.createElement('div', { id: 'headerItem__inWork', value: 'В роботі', className: 'headerItem inWork displayFlex', innerText: 'В роботі'});
        
        headerItem__overdue.style.backgroundImage = "url(assets/img/1551/crm1551_blue.png)";
        headerItem__notActive.style.backgroundImage = "url(assets/img/1551/crm1551_green.png)";
        
        headerItem__inWork.style.backgroundColor = 'rgba(173, 118, 205, 1)';
        headerItem__inWork.style.height = '42px';
        headerItem__inWork.style.marginTop = '2px';
        
        const headerItems = this.createElement('div', { id: 'headerItems', className: 'headerItems displayFlex'}, headerItem__overdue, headerItem__notActive, headerItem__inWork);
        const headerTitle = this.createElement('div', { id: 'headerTitle'});        
        const eventsHeader = this.createElement('div', { id: 'eventsHeader', className: 'orgContainer displayFlex'}, headerTitle, headerItems);
        const eventWrapper = this.createElement('div', {  id: 'eventWrapper', value: 0 , className: 'eventWrapper displayFlex'});
        tableContainer.appendChild(eventsHeader);
        tableContainer.appendChild(eventWrapper);
    },
};
}());
