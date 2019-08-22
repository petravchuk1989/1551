(function () {
  return {
    title: ' ',
    hint: '',
    formatTitle: function() {},
    customConfig:
                `
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
        this.sub = this.messageService.subscribe('reloadMainTable', this.reloadMainTable, this);
        
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
        this.createTabs();
        this.createFilters();
    },
    createTabs: function(){
        
        let tabInformation__title  = this.createElement('div', { className: 'tabInformation tab_title', innerText: 'ЗАГАЛЬНА ІНФОРМАЦІЯ'});
        let tabAction__title  = this.createElement('div', { className: 'tabAction tab_title', innerText: 'ЗАХІД'});
        let tabProcessingOrders__title  = this.createElement('div', { className: 'tabProcessingOrders tab_title', innerText: 'ОБРОБКА ДОРУЧЕНЬ'});
        let tabOrganizations__title  = this.createElement('div', { className: 'tabOrganizations tab_title', innerText: 'ОРГАНІЗАЦІЇ'});
        let tabFinder__title  = this.createElement('div', { className: ' tab_title', innerText: 'Розширений пошук'});
        
        const tabInformation = this.createElement('div', { id: 'tabInformation', url: '', className: 'tabInformation tab tabTo'}, tabInformation__title);
        const tabAction = this.createElement('div', { id: 'tabAction', url: 'performer_new_actions', className: 'tabAction tab tabTo'}, tabAction__title);
        const tabProcessingOrders = this.createElement('div', { id: 'tabProcessingOrders', url: 'performer_new_processing_assigments', className: 'tabProcessingOrders tab tabTo'}, tabProcessingOrders__title);
        const tabOrganizations = this.createElement('div', { id: 'tabOrganizations', url: 'performer_new_organizations', className: 'tabOrganizations tab tabHover'}, tabOrganizations__title);
        const tabFinder = this.createElement('div', { id: 'tabFinder', url: 'poshuk_table', className: 'tabFinder tab tabTo'}, tabFinder__title);
        
        
        const tabsContainer = this.createElement('div', { id: 'tabsContainer', className: 'tabsContainer'}, tabInformation, tabAction, tabProcessingOrders, tabOrganizations, tabFinder);
        tabsWrapper.appendChild(tabsContainer);
 
        let tabs = document.querySelectorAll('.tabTo');
        tabs.forEach( function (el){
            el.addEventListener( 'click', event => {
                let target =  event.currentTarget;
                document.getElementById('container').style.display = 'none';
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
        const headerItem__arrived_triangle = this.createElement('div', { className: 'arrived_triangle' });
        const headerItem__notCompetence_triangle = this.createElement('div', { className: 'notCompetence_triangle' });
        const headerItem__overdue_triangle = this.createElement('div', {  className: 'overdue_triangle' });
        const headerItem__warning_triangle = this.createElement('div', { className: 'warning_triangle' });
        const headerItem__inWork_triangle = this.createElement('div', {  className: 'inWork_triangle' });
        const headerItem__toAttention_triangle = this.createElement('div', {  className: 'toAttention_triangle ' });
        const headerItem__onRefinement_triangle = this.createElement('div', {  className: 'onRefinement_triangle ' });
        const headerItem__planOrProgram_triangle = this.createElement('div', { className: 'planOrProgram_triangle' });
        
        const headerItem__arrived         = this.createElement('div', { id: 'headerItem__arrived', className: 'headerItem displayFlex', innerText: 'Надійшло'}, headerItem__arrived_triangle);
        const headerItem__notCompetence   = this.createElement('div', { id: 'headerItem__notCompetence', className: 'headerItem displayFlex', innerText: 'Не в компетенції'}, headerItem__notCompetence_triangle);
        const headerItem__overdue         = this.createElement('div', { id: 'headerItem__overdue', className: 'headerItem displayFlex', innerText: 'Прострочені'}, headerItem__overdue_triangle);
        const headerItem__warning         = this.createElement('div', { id: 'headerItem__warning', className: 'headerItem displayFlex', innerText: 'Увага'}, headerItem__warning_triangle);
        const headerItem__inWork          = this.createElement('div', { id: 'headerItem__inWork', className: 'headerItem displayFlex', innerText: 'В роботі'}, headerItem__inWork_triangle);
        const headerItem__toAttention     = this.createElement('div', { id: 'headerItem__toAttention', className: 'headerItem displayFlex', innerText: 'До відома'}, headerItem__toAttention_triangle);
        const headerItem__onRefinement    = this.createElement('div', { id: 'headerItem__onRefinement', className: 'headerItem displayFlex', innerText: 'На доопрацюванні'}, headerItem__onRefinement_triangle);
        const headerItem__planOrProgram   = this.createElement('div', { id: 'headerItem__planOrProgram', className: 'headerItem displayFlex', innerText: 'План/Програма'}, headerItem__planOrProgram_triangle);
        
        headerItem__arrived.style.backgroundColor = "rgb(74, 193, 197)";
        headerItem__notCompetence.style.backgroundColor = "rgb(173, 118, 205)";
        headerItem__overdue.style.backgroundColor = "rgb(240, 114, 93)";
        headerItem__warning.style.backgroundColor = "rgb(238, 163, 54)";
        headerItem__inWork.style.backgroundColor = "rgb(132, 199, 96)";
        headerItem__toAttention.style.backgroundColor = "rgb(248, 195, 47)";
        headerItem__onRefinement.style.backgroundColor = "rgb(94, 202, 162)";
        headerItem__planOrProgram.style.backgroundColor = "rgba(73, 155, 199)";

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
            headers.forEach( el => {
                el.firstElementChild.classList.remove('triangle');
            });
            
            headerItem__arrived.style.backgroundColor = "rgb(74, 193, 197)";
            headerItem__notCompetence.style.backgroundColor = "rgb(173, 118, 205)";
            headerItem__overdue.style.backgroundColor = "rgb(240, 114, 93)";
            headerItem__warning.style.backgroundColor = "rgb(238, 163, 54)";
            headerItem__inWork.style.backgroundColor = "rgb(132, 199, 96)";
            headerItem__toAttention.style.backgroundColor = "rgb(248, 195, 47)";
            headerItem__onRefinement.style.backgroundColor = "rgb(94, 202, 162)";
            headerItem__planOrProgram.style.backgroundColor = "rgba(73, 155, 199)";
            
            headerItem__arrived.firstElementChild.classList.add('arrived_triangle');
            headerItem__notCompetence.firstElementChild.classList.add('notCompetence_triangle');
            headerItem__overdue.firstElementChild.classList.add('overdue_triangle');
            headerItem__warning.firstElementChild.classList.add('warning_triangle');
            headerItem__inWork.firstElementChild.classList.add('inWork_triangle');
            headerItem__toAttention.firstElementChild.classList.add('toAttention_triangle');
            headerItem__onRefinement.firstElementChild.classList.add('onRefinement_triangle');
            headerItem__planOrProgram.firstElementChild.classList.add('planOrProgram_triangle');
            
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
                        header.style.backgroundColor = "#d3d3d3";
                        header.classList.add('check');
                        header.firstElementChild.classList.remove(header.firstElementChild.classList[0]);
                        header.firstElementChild.classList.add('triangle');
                    }  
                    headers[7].firstElementChild.classList.remove('triangle');
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
    destroy: function(){
        this.sub.unsubscribe();
    }
 
};
}());
