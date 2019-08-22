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
                .columnWrapper{
                    position: relative;
                }
                .orgName{
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
                .tab_title{
                    text-transform: uppercase;
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
                .organization{
                    height: 100%;
                    background-color: rgba(240, 240, 240, 1);
                    margin: 3px 0;
                }
                .orgElements{
                    flex-direction: column;
                }
                .orgTitle{
                    max-width: 200px;
                    min-width: 200px;
                    padding: 10px;
                }
                .orgTitle__icon{
                    cursor: pointer;
                    margin: 0 7px;
                    display: flex;
                }
                .orgTitle__name{
                    margin: 2px 0;
                    display: flex;
                }
                .counter{
                    width: 150px;
                    height: 50px;
                    background-color: #fff;
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
                    margin: 0 2px;
                }
                .referalColumn{
                    align-items: center;
                    justify-content: center;                    
                    flex-direction: column;
                    font-size: 12px;
                }
                .referalItem{
                    margin: 5px 10px 5px 3px;
                }
                .emptyBox{
                    width: 150px;
                    margin: 5px 10px 5px 3px;
                }                
                .counterHeader{
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    flex-direction: row;
                    margin: 5px 10px 5px 3px;
                }
                #orgHeader{
                    margin-bottom: 10px;                    
                }
                #headerTitle{
                    margin-top: 2px;
                    background-color: rgba(240 240 240);
                    width: 203px;
                    font-size: 14px;
                    font-weight: 400;
                    font-style: normal;
                    font-size: 14px;
                    color: rgb(153, 153, 153);
                    text-align: left;
                    height: 42px;
                    display: flex;
                    align-items: center;
                    justify-content: center;                
                }
                #headerItems{
                    position: relative;                    
                }
                .headerItem{
                    background-position-x: -93px;
                    width: 180px;
                    position: absolute;
                    height: 46px;
                    align-items: center;
                    justify-content: center;
                    background-repeat: no-repeat;
                    font-weight: 400;
                    font-style: normal;
                    font-size: 16px;
                    color: #FFFFFF;
                    cursor: pointer;
                } 
                #headerItem__arrived{
                    z-index: 180;
                }
                #headerItem__notCompetence{
                    z-index: 170;
                    left: 154px;
                }
                #headerItem__overdue{
                    z-index: 160;
                    left: 317px;
                }
                #headerItem__warning{
                    z-index: 150;
                    left: 480px;
                }
                #headerItem__inWork{
                    z-index: 140;
                    left: 643px;
                }
                #headerItem__toAttention{
                    z-index: 130;
                    left: 806px;
                }
                #headerItem__onRefinement{
                    z-index: 120;
                    left: 968px;
                }
                #headerItem__planOrProgram{
                    border: 2px solid #fff;
                    height: 46px;
                    z-index: 110;
                    left: 1122px;
                    width: 204px;
                    padding-left: 15px;                    
                }
                .orgElementsReferral {
                    height: 100%;
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
        
        this.column = [];
        this.navigator = [];
        this.targetId = [];
        this.messageService.subscribe('reloadMainTable', this.reloadMainTable, this);
        
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
            queryCode: 'table3',
            limit: -1,
            parameterValues: [ { key: '@organization_id',  value: this.organizationId }  ]
        };
        this.queryExecutor(executeQueryOrganizations, this.createSubordinateOrganizationsTable.bind(this, false, null), this);
        
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
        document.getElementById('organizationName').value = (data.rows[0].values[indexOfTypeId]);
        document.getElementById('organizationName').innerText = (data.rows[0].values[indexOfTypeName]);
        this.organizationName = data.rows[0].values[indexOfTypeName];
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
        // container.appendChild(tableWrapper);
        this.createTabs();
        this.createFilters();
    },
    createTabs: function(){
        
        let tabFinder__title  = this.createElement('div', { className: ' tab_title', innerText: 'Розширений пошук'});
        let tabInformation__title  = this.createElement('div', { className: ' tab_title', innerText: 'ЗАГАЛЬНА ІНФОРМАЦІЯ'});
        let tabAction__title  = this.createElement('div', { className: ' tab_title', innerText: 'ЗАХІД'});
        let tabProcessingOrders__title  = this.createElement('div', { className: ' tab_title', innerText: 'ОБРОБКА ДОРУЧЕНЬ'});
        let tabOrganizations__title  = this.createElement('div', { className: ' tab_title', innerText: 'ОРГАНІЗАЦІЇ'});
        
        
        const tabFinder = this.createElement('div', { id: 'tabFinder', url: 'poshuk_table', className: 'tabFinder tab'}, tabFinder__title);
        const tabInformation = this.createElement('div', { id: 'tabInformation', url: '', className: 'tabInformation tab'}, tabInformation__title);
        const tabAction = this.createElement('div', { id: 'tabAction', url: 'performer_new_actions', className: 'tabAction tab'}, tabAction__title);
        const tabProcessingOrders = this.createElement('div', { id: 'tabProcessingOrders', url: 'performer_new_processing_assigments', className: 'tabProcessingOrders tab'}, tabProcessingOrders__title);
        const tabOrganizations = this.createElement('div', { id: 'tabOrganizations', url: 'performer_new_organizations', className: 'tabOrganizations tab tabHover'}, tabOrganizations__title);
        
        
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
        const organizationName = this.createElement('div', {id: 'organizationName', className: 'orgName'});
        const organizationChildCat = this.createElement('div', {id: 'organizationChildCat', className: 'orgName', innerText: ' '});
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
                orgContainer.style.display = 'none';
                this.resultSearch('resultSearch', searchContainer__input.value);
                this.resultSearch('clickOnTable2', 'none');
                let headerItems = document.querySelectorAll('.headerItem');
                headerItems.forEach(el => {
                    el.classList.add('check');
                });
            }
        }.bind(this));
        
        filtersWrapper.appendChild(organizationName);
        filtersWrapper.appendChild(organizationChildCat);
        filtersWrapper.appendChild(searchContainer);
    },
    reloadMainTable: function(message){
        document.getElementById('container').removeChild(document.getElementById('orgHeader'));
        document.getElementById('container').removeChild(document.getElementById('orgContainer'));
        this.column = message.column;
        this.navigator = message.navigator;
        let targetId = message.targetId;
        let executeQueryOrganizations = {
            queryCode: 'table3',
            limit: -1,
            parameterValues: [ { key: '@organization_id',  value: this.organizationId }  ]
        };
        this.queryExecutor(executeQueryOrganizations, this.createSubordinateOrganizationsTable.bind(this, true, targetId, ), this);
    },
    createSubordinateOrganizationsTable: function(reloadTable, targetId, data){
        this.createHeaderOrganizations();
        let orgElementsReferral__arrived         = this.createElement('div', {position: 'header', className: 'headerItem displayFlex'});
        let orgElementsReferral__notCompetence   = this.createElement('div', {position: 'header', className: 'headerItem displayFlex'});
        let orgElementsReferral__overdue         = this.createElement('div', {position: 'header', className: 'headerItem displayFlex'});
        let orgElementsReferral__warning         = this.createElement('div', {position: 'header', className: 'headerItem displayFlex'});
        let orgElementsReferral__inWork          = this.createElement('div', {position: 'header', className: 'headerItem displayFlex'});
        let orgElementsReferral__toAttention     = this.createElement('div', {position: 'header', className: 'headerItem displayFlex'});
        let orgElementsReferral__onRefinement    = this.createElement('div', {position: 'header', className: 'headerItem displayFlex'});
        let orgElementsReferral__planOrProgram   = this.createElement('div', {position: 'header', className: 'headerItem displayFlex'});
        const orgContainer = this.createElement('div', { id: 'orgContainer', className: 'orgContainer'});
        container.appendChild(orgContainer);
        data.rows.forEach( function(row){
            
            let orgElementsReferral__arrived         = this.createElement('div', { className: 'referalColumn'});
            let orgElementsReferral__notCompetence   = this.createElement('div', { className: 'referalColumn'});
            let orgElementsReferral__overdue         = this.createElement('div', { className: 'referalColumn'});
            let orgElementsReferral__warning         = this.createElement('div', { className: 'referalColumn'});
            let orgElementsReferral__inWork          = this.createElement('div', { className: 'referalColumn'});
            let orgElementsReferral__toAttention     = this.createElement('div', { className: 'referalColumn'});
            let orgElementsReferral__onRefinement    = this.createElement('div', { className: 'referalColumn'});
            let orgElementsReferral__planOrProgram   = this.createElement('div', { className: 'referalColumn'});
            
            var organizationId = row.values[0];
            
            let orgElementsReferral = this.createElement('div', {  className: 'orgElementsReferral displayNone'}, orgElementsReferral__arrived, orgElementsReferral__notCompetence, orgElementsReferral__overdue, orgElementsReferral__warning, orgElementsReferral__inWork, orgElementsReferral__toAttention, orgElementsReferral__onRefinement, orgElementsReferral__planOrProgram);
            let orgElementsСounter = this.createElement('div', {  className: 'orgElementsСounter displayFlex'});
            let orgElements = this.createElement('div', {  className: 'orgElements displayFlex'}, orgElementsСounter, orgElementsReferral);
            let orgTitle__icon = this.createElement('div', {  className: 'orgTitle__icon material-icons',value: 0 , innerText: 'add_circle_outline'});
            let orgTitle__name = this.createElement('div', {  className: 'orgTitle__name', innerText: ''+row.values[1]+''});
            let orgTitle = this.createElement('div', {  className: 'orgTitle displayFlex'}, orgTitle__icon, orgTitle__name);
            let organization = this.createElement('div', {  className: 'organization displayFlex', id: ''+organizationId+''}, orgTitle, orgElements);
            orgContainer.appendChild(organization);
              
            for( let i = 2;  i <row.values.length; i ++){
                let el = row.values[i];
                
                var column =  this.chooseColumnName(i);
                if( el != 0 ){
                    let orgElementsСounterItem__value = this.createElement('div', {  className: ' counter_value', innerText: ''+el+''});
                    var orgElementsСounterItem = this.createElement('div', {orgId: organizationId,  column: column, orgName: ''+row.values[1]+'',  className: 'counter counterHeader'}, orgElementsСounterItem__value);
                }else{
                    var orgElementsСounterItem = this.createElement('div', {  className: 'counter counterHeader'});
                }
                orgElementsСounter.appendChild(orgElementsСounterItem);
            }
            let executeQuery = {
                queryCode: 'table2',
                parameterValues: [{ key: '@organization_id',  value: row.values[0]}],
                limit: -1
            };
            this.queryExecutor(executeQuery, this.createOrganizationsSubElements.bind( this, orgElementsReferral, organizationId ), this);
        }.bind(this));
        
        let allIcons = document.querySelectorAll('.orgTitle__icon');
        allIcons.forEach( el =>{
            el.addEventListener( 'click', event => {
                let target = event.currentTarget;
                if( target.value == 0){
                    target.parentElement.nextElementSibling.firstElementChild.classList.remove('displayFlex');
                    target.parentElement.nextElementSibling.firstElementChild.classList.add('displayNone');
                    target.parentElement.nextElementSibling.lastElementChild.classList.remove('displayNone');
                    target.parentElement.nextElementSibling.lastElementChild.classList.add('displayFlex');
                    target.value = 1;
                    target.innerText = 'remove_circle_outline';
                }else if( target.value == 1){
                    target.value = 0;
                    target.innerText = 'add_circle_outline';
                    target.parentElement.nextElementSibling.lastElementChild.classList.remove('displayFlex');
                    target.parentElement.nextElementSibling.lastElementChild.classList.add('displayNone');
                    target.parentElement.nextElementSibling.firstElementChild.classList.remove('displayNone');
                    target.parentElement.nextElementSibling.firstElementChild.classList.add('displayFlex');
                }
            });
        });
        let counterHeaderElements = document.querySelectorAll('.counter');
        counterHeaderElements.forEach( el => {
            if(el.childNodes.length == 0 ){
                el.style.backgroundColor = 'transparent';
            }else{
                el.classList.add('counterBorder');
            }
        });
        let referalColumnElements = document.querySelectorAll('.referalColumn');
        referalColumnElements.forEach( function(el) {
            if( el.childNodes.length == 0){
                let emptyBox = this.createElement('div', {  className: 'emptyBox'});
                el.appendChild(emptyBox);
            }
        }.bind(this));  
        
        
        if( reloadTable == true ){
            let target = document.getElementById(targetId);
            let thisName = document.getElementById('organizationName').innerText;
            this.showTable(target,  this.column, this.navigator, thisName ,'item' );
        }
    },
    createHeaderOrganizations: function(){
        const headerItem__arrived         = this.createElement('div', { id: 'headerItem__arrived', className: 'headerItem displayFlex', innerText: 'Надійшло'});
        const headerItem__notCompetence   = this.createElement('div', { id: 'headerItem__notCompetence', className: 'headerItem displayFlex', innerText: 'Не в компетенції'});
        const headerItem__overdue         = this.createElement('div', { id: 'headerItem__overdue', className: 'headerItem displayFlex', innerText: 'Прострочені'});
        const headerItem__warning         = this.createElement('div', { id: 'headerItem__warning', className: 'headerItem displayFlex', innerText: 'Увага'});
        const headerItem__inWork          = this.createElement('div', { id: 'headerItem__inWork', className: 'headerItem displayFlex', innerText: 'В роботі'});
        const headerItem__toAttention     = this.createElement('div', { id: 'headerItem__toAttention', className: 'headerItem displayFlex', innerText: 'До відома'});
        const headerItem__onRefinement    = this.createElement('div', { id: 'headerItem__onRefinement', className: 'headerItem displayFlex', innerText: 'На доопрацюванні'});
        const headerItem__planOrProgram   = this.createElement('div', { id: 'headerItem__planOrProgram', className: 'headerItem displayFlex', innerText: 'План/Програма'});
        
        headerItem__arrived.style.backgroundImage = "url(assets/img/1551/crm1551_blue.png)";
        headerItem__notCompetence.style.backgroundImage = "url(assets/img/1551/crm1551_purple.png)";
        headerItem__overdue.style.backgroundImage = "url(assets/img/1551/crm1551_red.png)";
        headerItem__warning.style.backgroundImage = "url(assets/img/1551/crm1551_orange.png)";
        headerItem__inWork.style.backgroundImage = "url(assets/img/1551/crm1551_green.png)";
        headerItem__toAttention.style.backgroundImage = "url(assets/img/1551/crm1551_yellow.png)";
        headerItem__onRefinement.style.backgroundImage = "url(assets/img/1551/crm1551_green.png)";
        headerItem__planOrProgram.style.backgroundColor = "rgba(73, 155, 199, 1)";
        headerItem__planOrProgram.style.border = '2px solid #fff';

        const headerItems = this.createElement('div', { id: 'headerItems', className: 'displayFlex'}, headerItem__arrived, headerItem__notCompetence, headerItem__overdue, headerItem__warning, headerItem__inWork, headerItem__toAttention, headerItem__onRefinement, headerItem__planOrProgram);
        const headerTitle = this.createElement('div', { id: 'headerTitle', innerText: 'Підлеглі організації'});        
        const orgHeader = this.createElement('div', { id: 'orgHeader', className: 'orgContainer displayFlex'}, headerTitle, headerItems);
        
        container.appendChild(orgHeader);
        
        
        var headers = document.querySelectorAll('.headerItem');
        console.log(headers)
        headers.forEach( function(el){
            el.addEventListener( 'click', function(event){
                let target = event.currentTarget;
                // this.target = target;
                let navigator = 'Усі';
                let column = target.innerText;
                this.showTable(target, column, navigator,  undefined,'headers');
            }.bind(this));
        }.bind(this));
    },
    createOrganizationsSubElements: function(orgElementsReferral, organizationId, data){
        data.rows.forEach( function(row){
            for( let i = 2;  i <row.values.length; i ++){
                var el = row.values[i];
                var sub = row.values[1];
                var column =  this.chooseColumnName(i);
                if( el != 0 ){
                    let orgElementsReferal__itemValue_number = this.createElement('div', {  className: 'refItem__value', innerText: ' ('+el+')'});
                    let orgElementsReferal__itemValue_title = this.createElement('div', {  className: 'refItem__value', innerText: ''+sub+' '});
                    let orgElementsReferal__itemValue = this.createElement('div', { className: 'refItem__value'}, orgElementsReferal__itemValue_title, orgElementsReferal__itemValue_number);
                    let orgElementsReferal__item = this.createElement('div', { orgId: organizationId, column: column, orgName: ''+row.values[1]+'',   className: 'counter referalItem counterBorder'}, orgElementsReferal__itemValue);
                    orgElementsReferral.childNodes[i-2].appendChild(orgElementsReferal__item);
                }
            }
        }.bind(this));
        
        let counters = document.querySelectorAll('.counterBorder');
        
        counters.forEach( function(el){
            el.addEventListener( 'click', function(event){
                event.stopImmediatePropagation();
                let target = event.currentTarget;
                if( target.classList.contains('counterHeader')){
                    var navigator = 'Усі';
                    var thisName = target.orgName;
                }else{
                    var navigator = target.firstElementChild.firstElementChild.innerText;
                    var thisName = target.parentElement.parentElement.parentElement.parentElement.firstElementChild.lastElementChild.innerText;
                }
                
                // var organizationId = target.orgId;
                this.targetOrgId = target.orgId;
                let column = target.column;
                switch(column) {
                    case 'Надійшло':  
                        target = document.getElementById('headerItem__arrived')
                        break;
                    case 'Не в компетенції': 
                        target =  document.getElementById('headerItem__notCompetence')
                        break;
                    case 'Прострочені':
                        target =  document.getElementById('headerItem__overdue')
                        break;
                    case 'Увага':
                        target =  document.getElementById('headerItem__warning')
                        break;
                    case 'В роботі':
                        target =  document.getElementById('headerItem__inWork')
                        break;
                    case 'До відома':
                        target =  document.getElementById('headerItem__toAttention')
                        break;
                    case 'На доопрацюванні':
                        target =  document.getElementById('headerItem__onRefinement')
                        break;
                    case 'План/Програма':
                        target = document.getElementById('headerItem__planOrProgram') 
                        break;
                }
                // this.target = target;
                this.showTable(target, column, navigator, thisName, 'item');
            }.bind(this));
        }.bind(this));
    },
    chooseColumnName: function(i){
        switch(i) {
            case 2:  
                column = 'Надійшло'
                break;
            case 3: 
                column = 'Не в компетенції'
                break;
            case 4:
                column = 'Прострочені'
                break;
            case 5:
                column = 'Увага'
                break;
            case 6:
                column = 'В роботі'
                break;
            case 7:
                column = 'До відома'
                break;
            case 8:
                column = 'На доопрацюванні'
                break;
            case 9:
                column = 'План/Програма'
                break;
        }
        return column
    },
    showTable: function(target, columnName, navigator, thisName, position){
        const headers = document.querySelectorAll('.headerItem');
        if( target.classList.contains('check') || target.classList.contains('hover') || target.id == 'searchContainer__input'){
            
            headerItem__arrived.style.backgroundImage = "url(assets/img/1551/crm1551_blue.png)";
            headerItem__notCompetence.style.backgroundImage = "url(assets/img/1551/crm1551_purple.png)";
            headerItem__overdue.style.backgroundImage = "url(assets/img/1551/crm1551_red.png)";
            headerItem__warning.style.backgroundImage = "url(assets/img/1551/crm1551_orange.png)";
            headerItem__inWork.style.backgroundImage = "url(assets/img/1551/crm1551_green.png)";
            headerItem__toAttention.style.backgroundImage = "url(assets/img/1551/crm1551_yellow.png)";
            headerItem__onRefinement.style.backgroundImage = "url(assets/img/1551/crm1551_green.png)";
            headerItem__planOrProgram.style.backgroundColor = "rgba(73, 155, 199, 1)";
             
            document.getElementById('organizationName').innerText = this.organizationName;
            document.getElementById('organizationChildCat').innerText = ' ';
            headers.forEach( function(el) {
                el.classList.remove('hover'); 
                el.classList.remove('check'); 
            }.bind(this));
            orgContainer.style.display = 'block';
            this.sendMesOnBtnClick('clickOnTable2', 'none', 'none');
            this.resultSearch('clearInput', 0);
            searchContainer__input.value = '';
        }else{
            if(  thisName == undefined ){
                document.getElementById('organizationName').innerText = this.organizationName;
                document.getElementById('organizationChildCat').innerText = ' ';
            }else{
                document.getElementById('organizationChildCat').innerText = navigator;
                document.getElementById('organizationName').innerText = thisName;
            }
            if (position == 'item'){
                target.classList.add('hover');
                orgContainer.style.display = 'none';
                headers.forEach( function(target, header) {
                    let headers = document.querySelectorAll('.headerItem');
                    
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
                this.sendMesOnBtnClick('clickOnTable2', columnName, navigator, thisName, this.targetOrgId, target.id);
            }
        }
    },
    sendMesOnBtnClick: function(message, column, navigator, thisName, organizationId, targetId){
        this.messageService.publish({name: message, column: column,  navigation: navigator, orgId: organizationId, orgName: thisName, targetId: targetId });
    },    
    resultSearch: function(message, value){
        this.messageService.publish({name: message, value: value, orgId: this.organizationId});
    }, 
};
}());
