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
                .tabTitle{
                    font-family: 'Roboto-Regular';
                    text-transform: uppercase;
                }
                .columnWrapper{
                    position: relative;
                }
                #filtersWrapper{
                    display: flex;
                    flex-direction: row;
                    justify-content: space-between;
                    padding: 10px 0 10px 20px;
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
                    margin-left: 32px;
                    border-bottom: 1px solid rgba(204 204 204);                    
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
                
                #filtersContainer{
                    display: flex;
                    flex-wrap: wrap;
                    min-width: 60%;
                    max-width: 77%;
                }
                .filter{
                    cursor: pointer;
                    justify-content: space-between;
                    height: 34px;
                    font-size: 12px;
                    border-width: 0px;
                    color: rgba(0, 0, 0, 0.537254901960784);
                    border-radius: 16px;
                    display: flex;
                    align-items: center;  
                    background-color: rgba(239, 247, 249, 1); 
                    margin: 5px 10px;
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
                    font-family: 'Roboto';
                    font-weight: 400;
                    font-style: normal;
                    font-size: 12px;
                    color: #333333;
                    text-align: center;
                    line-height: normal;                    
                }
                .filterWrapper{
                    position: relative;
                }
                
                .filter_closer_hide{
                    width: 20px;
                    height: 20px;
                    background: transparent;
                    margin-right: 3px;
                }    
                .filter_closer_show{
                    width: 20px;
                    height: 20px;
                    border-radius: 50%;
                    background-color: rgba(21, 189, 244, 1);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: #fff;
                    font-size: 16px;
                    margin-right: 3px;
                }
                .filtersBox{
                    position: fixed;
                    display: flex;
                    width: 100%;
                    height: 100%;
                    justify-content: center;
                    align-items: center;
                    background: rgba(0,0,0,.7);
                    z-index: 900;
                    top: 44px;
                    left: 0;
                }
                .searchContainer__input{
                    height: 34px;
                    width: 220px;
                    padding: 5px;
                    outline-style: none;
                    margin: 5px 0;
                }
                #filterEdit{
                    cursor: pointer;
                    color: #cccbcb;
                    height: 100%;
                    display: flex;
                    align-items: center;   
                    margin: 10px 0;
                }
                #header1{
                    z-index: 100;
                }
                #modalWindow{
                    position: fixed;
                    top: 110px;
                    margin-left: 50%;
                    left: -450px;
                    z-index: 950;
                    background: #fafafa;
                    width: 100%;
                    max-width: 900px;
                    padding: 15px;   
                }
                #modalHeader{
                    width: 100%;
                    display: flex;
                    flex-direction: row; 
                    align-items: center;
                    justify-content: space-between;  
                }
                #modalFilters{
                    margin-top: 20px;
                    display: flex;
                    flex-direction: column; 
                }
                #modalFiltersContainer{
                    display: flex;
                    flex-direction: column;
                }
                .modalFiltersContainerItem{
                    display: flex;
                    flex-direction: row;
                }
                #modalFiltersHeader{
                    display: flex;
                    width: 100%;
                    border-top: 1px solid #acada8;
                    border-bottom: 1px solid #acada8;                    
                }
                #modalFiltersHeader__district{
                    width: 30%;
                    padding: 5px 10px;
                    color: #acada8;
                }
                #modalFiltersHeader__categorie{
                    width: 70%;
                    padding: 5px 0;
                    color: #acada8;
                }
                .modalFiltersContainer__district{
                    width: 30%;
                    padding: 5px 10px;
                }
                .modalFiltersContainer__categorie{
                    width: 70%;
                    padding: 5px 0;                    
                }
                .districtItem{
                    width: 100%;
                }
                .districtItemSelect{
                    width: 90%;
                }
                .selectItem{
                    background: transparent;
                    border: none;
                    border-bottom: 1px solid #acada8;
                    margin: 10px 0;
                    font-size: 14px;
                    outline: none;
                }
                .modalBtn{
                    text-transform: uppercase;
                    outline: none;
                    cursor: pointer;
                    padding: 10px 15px;
                    margin: 0 5px;
                }
                #modalHeader__button_save{
                    background-color: rgba(21, 189, 244, 1);
                    border: none;
                    border-radius: 5px;
                    color: #fff;
                    
                }
                #modalHeader__button_close{
                    background-color: transparent;
                    color: rgba(21, 189, 244, 1);
                    border: none;
                }
                .select2{
                    width: 90%!important;
                    outline: none;                    
                }
                .select2-selection{
                    border-radius: 0px!important;
                    outline: none; 
                    border: none!important;
                    border-bottom: 1px solid #acada8!important;
                }
                </style>
                    <div id = 'container'></div>
                `
    ,
    isLoadDistrict: false,
    isLoadCategorie: false,
    isDistrictFull: false,
    isCategorieFull: false,
    init: function() {
        this.hidePagePreloader();
        this.messageService.publish( { name: 'showPagePreloader'});    
        this.messageService.subscribe('reloadMainTable', this.reloadMainTable, this);
        this.column = [];
        this.navigator = [];
        const header = document.getElementById('header1');
        header.firstElementChild.style.overflow = 'visible';
        header.firstElementChild.firstElementChild.firstElementChild.style.overflow = 'visible';
        let executeQueryTable = {
            queryCode: 'CoordinatorController_table',
            limit: -1,
            parameterValues: []
        };
        this.queryExecutor(executeQueryTable, this.createTable.bind(this,  false ), this);
        
        let executeQueryFilters = {
            queryCode: 'cc_FilterName',
            limit: -1,
            parameterValues: []
        };
        this.queryExecutor(executeQueryFilters, this.createFilters, this);
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
    reloadMainTable: function(message){
        
        while ( tableContainer.hasChildNodes() ) {
            tableContainer.removeChild( tableContainer.childNodes[0] );
        }        
        console.log(tableWrapper)
        if(message){
            this.column = message.column;
            this.navigation = message.navigation;
            this.targetId = message.targetId;
            var reloadTable = true;
        }else{
            var reloadTable = false;
        }
        let executeQueryTable = {
            queryCode: 'CoordinatorController_table',
            limit: -1,
            parameterValues: []
        };
        this.queryExecutor(executeQueryTable, this.createTable.bind(this,  reloadTable ), this);
        this.showPreloader = false;
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
    },
    createTabs: function(){
        
        let tabPhone__title  = this.createElement('div', { className: 'tabTitle', innerText: 'ВХІДНИЙ ДЗВІНОК'});
        let tabAppeal__title  = this.createElement('div', { className: 'tabTitle', innerText: 'РЕЄСТРАЦІЯ ЗВЕРНЕНЬ'});
        let tabAssigment__title  = this.createElement('div', { className: 'tabTitle', innerText: 'ОБРОБКА ДОРУЧЕНЬ'});
        let tabFinder__title  = this.createElement('div', { className: ' tabTitle', innerText: 'Розширений пошук'});
        
        const tabPhone = this.createElement('div', { id: 'tabPhone', location: 'dashboard', url: 'StartPage_operator', className: 'tabPhone tab'}, tabPhone__title);
        const tabAppeal = this.createElement('div', { id: 'tabAppeal', location: 'section', url: '', className: 'tabAppeal tab'}, tabAppeal__title);
        const tabAssigment = this.createElement('div', { id: 'tabAssigment', location: 'dashboard', url: 'coordinotar_new', className: 'tabAssigment tab tabHover'}, tabAssigment__title);
        const tabFinder = this.createElement('div', { id: 'tabFinder', location: 'dashboard',  url: 'poshuk_table', className: 'tabFinder tab'}, tabFinder__title);
        
        const tabsContainer = this.createElement('div', { id: 'tabsContainer', className: 'tabsContainer'},tabPhone ,tabAppeal ,tabAssigment, tabFinder);
        tabsWrapper.appendChild(tabsContainer);
        
        let tabs = document.querySelectorAll('.tab');
        
        tabs.forEach( function (el){
            el.addEventListener( 'click', event => {
                let target =  event.currentTarget;
                let tabs = document.querySelectorAll('.tab');
                if( target.location == 'section'){
                    this.goToSection(target.url);
                }else if( target.location == 'dashboard'){
                    this.goToDashboard(target.url);
                }
            });   
        }.bind(this));
    },
    createFilters: function(data){
        this.data = data;
        let filtersBox =  this.createElement('div', { id: 'filtersBox' });
        const filterEdit =  this.createElement('div', { id: 'filterEdit', className: "material-icons", innerText: 'edit'});
        filterEdit.addEventListener('click', function (event){

            let target = event.currentTarget;
            if( filtersBox.classList.contains('filtersBox')){
            }else{
                console.log(this.data)
                this.createModalForm(filtersBox, 'new', this.data);
            }
        }.bind(this, filtersBox));
        const filtersContainer =  this.createElement('div', { id: 'filtersContainer', className: "filtersContainer"});
        
        for ( i = 0; i < data.rows.length; i++){
            let row = data.rows[i];
            let filter_closer = this.createElement('div', { className: 'filter_closer filter_closer_hide'});
            let filter__icon = this.createElement('div', { className: " filterIcon material-icons", innerText: 'filter_list'});
            let filter__title = this.createElement('div', {  className: "filterTitle", innerText: ''+row.values[1]+''});
            let filterWrapper  =  this.createElement('div', { id: ''+row.values[0]+'', district_id: ''+row.values[2]+'', question_id: ''+row.values[3]+'', className: "filter"}, filter__icon, filter__title, filter_closer);
            filtersContainer.appendChild(filterWrapper);
        }
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
                this.resultSearch('resultSearch', searchContainer__input.value);
                this.hideAllItems(0);
            }
        }.bind(this));
        

        filtersWrapper.appendChild(filtersContainer);
        filtersWrapper.appendChild(filterEdit);
        filtersWrapper.appendChild(filtersBox);
        filtersWrapper.appendChild(searchContainer);
        
        
        let filters = document.querySelectorAll('.filter');
        console.log(filters)
        filters.forEach( item => {
            item.addEventListener( 'mouseover', event => {
                let target = event.currentTarget;
                target.childNodes[2].classList.add('material-icons');
                target.childNodes[2].classList.remove('filter_closer_hide');
                target.childNodes[2].classList.add('filter_closer_show');
                target.childNodes[2].innerText = 'close';
            });
        });
        filters.forEach( item => {
            item.addEventListener( 'mouseout', event => {
                let target = event.currentTarget;
                target.childNodes[2].classList.remove('material-icons');
                target.childNodes[2].classList.remove('filter_closer_show');
                target.childNodes[2].classList.add('filter_closer_hide');
                target.childNodes[2].innerText = '';
            });
        });
        let filter_closer = document.querySelectorAll('.filter_closer');
        filter_closer.forEach( function(el){
            el.addEventListener( 'click', function(event){
                let target = event.currentTarget;
                let executeQueryDeleteFilter = {
                    queryCode: 'cc_FilterDelete',
                    limit: -1,
                    parameterValues: [
                            { key: '@id', value: Number(target.parentElement.id)}
                        ]
                };
                this.queryExecutor(executeQueryDeleteFilter);
                this.showPreloader = false;
                document.getElementById('filtersContainer').removeChild(document.getElementById(target.parentElement.id));
                let executeQueryFilters = {
                    queryCode: 'cc_FilterName',
                    limit: -1,
                    parameterValues: []
                };
                this.queryExecutor(executeQueryFilters, this.setNewData, this);
                this.showPreloader = false;
            }.bind(this));
        }.bind(this));
        
    },
    createModalForm: function(filtersBox, param, data){
        if( filtersBox.parentElement == null){
            filtersWrapper.appendChild(filtersBox);
        }
        while ( filtersBox.hasChildNodes() ) {
                filtersBox.removeChild( filtersBox.childNodes[0] );
        }
        filtersBox.classList.add('filtersBox');
        const modalHeader__button_close  =  this.createElement('button', { id: 'modalHeader__button_close', className: 'modalBtn', innerText: 'Закрити'});
        const modalHeader__button_save  =  this.createElement('button', { id: 'modalHeader__button_save', className: 'modalBtn', innerText: 'Зберегти'});
        const modalHeader__buttonWrapper =  this.createElement('div', { id: 'modalHeader__buttonWrapper'}, modalHeader__button_close, modalHeader__button_save);
        const modalHeader__caption =  this.createElement('div', { id: 'modalHeader__caption', innerText: 'Налаштування фiльтрiв'});
        
        const modalFiltersContainer =  this.createElement('div', { id: 'modalFiltersContainer'});
        const modalFiltersHeader__categorie =  this.createElement('div', {className: 'filHeadCategorie', id: 'modalFiltersHeader__categorie', innerText: 'НАПРЯМОК РОБIТ'});
        const modalFiltersHeader__district =  this.createElement('div', {className: 'filHeadDistrict', id: 'modalFiltersHeader__district', innerText: 'РАЙОН'});
        const modalFiltersHeader =  this.createElement('div', { id: 'modalFiltersHeader'}, modalFiltersHeader__district, modalFiltersHeader__categorie);
        const modalFilters =  this.createElement('div', { id: 'modalFilters'}, modalFiltersHeader, modalFiltersContainer);
        const modalHeader  =  this.createElement('div', { id: 'modalHeader'}, modalHeader__caption, modalHeader__buttonWrapper);
        const modalWindow  =  this.createElement('div', { id: 'modalWindow'}, modalHeader, modalFilters);
        modalWindow.style.display = 'block';
        filtersBox.appendChild(modalWindow);
        this.createModalFiltersContainerItems(data, modalFiltersContainer);
        
        modalHeader__button_save.addEventListener( 'click', function(event){
            let target = event.currentTarget;
            
            while ( filtersWrapper.hasChildNodes() ) {
                filtersWrapper.removeChild( filtersWrapper.childNodes[0] );
            }
            let executeQueryFilters = {
                queryCode: 'cc_FilterName',
                limit: -1,
                parameterValues: []
            };
            this.queryExecutor(executeQueryFilters, this.createFilters, this);
            this.showPreloader = false;
            filtersBox.classList.remove('filtersBox');
            filtersBox.remove(filtersBox.childNodes[0]);
            this.sendMesOnBtnClick('clickOnСoordinator_table', 'none', 'none');
            this.reloadMainTable();
            this.messageService.publish( { name: 'showPagePreloader'});
            
        }.bind(this));
        modalHeader__button_close.addEventListener( 'click', function(event){
            let target = event.currentTarget;
            filtersBox.classList.remove('filtersBox');
            filtersBox.remove(filtersBox.childNodes[0]);
            
        }.bind(this));
    },
    createModalFiltersContainerItems: function(data, modalFiltersContainer){
        data.rows.forEach( function (el){
            var districtId = el.values[2];
            var categorieId = el.values[3];
            
            let categorieItemSelect  =  this.createElement('select', { className: "categorieItemSelect selectItem js-example-basic-single"});
            let categorieItem  =  this.createElement('div', { className: "districtItem"}, categorieItemSelect);
            let districtItemSelect  =  this.createElement('select', { className: "districtItemSelect selectItem  js-example-basic-single"});
            let districtItem  =  this.createElement('div', { className: "districtItem"}, districtItemSelect);
            
            const modalFiltersContainerItem__categorie =  this.createElement('div', { className: 'modalFiltersContainer__categorie'}, categorieItem);
            const modalFiltersContainerItem__district =  this.createElement('div', { className: 'modalFiltersContainer__district'}, districtItem);
            const modalFiltersContainerItem =  this.createElement('div', { className: 'modalFiltersContainerItem'}, modalFiltersContainerItem__district, modalFiltersContainerItem__categorie);
            
            this.isLoadDistrict = false;
            this.isLoadCategory = false;
            
            this.messageService.publish( { name: 'showPagePreloader'});
            modalFiltersContainer.appendChild(modalFiltersContainerItem);
            
            let executeQueryDisctict = {
                queryCode: 'cc_FilterDistrict',
                limit: -1,
                parameterValues: []
            };
            this.queryExecutor(executeQueryDisctict, this.createFilterDistrict.bind(this, districtId, districtItemSelect), this);
            this.showPreloader = false;
            
            let executeQueryCategories = {
                queryCode: 'cc_FilterQuestionTypes',
                limit: -1,
                parameterValues: []
            };
            this.queryExecutor(executeQueryCategories, this.createFilterCategories.bind( this, categorieId, categorieItemSelect), this);
            this.showPreloader = false;
            
        }.bind(this));
    
        let categorieNewItemSelect  =  this.createElement('select', {id: 'categorieNewItemSelect',  className: "categorieItemSelect selectItem js-example-basic-single js-example-placeholder-categorie"});
        let categorieNewItem  =  this.createElement('div', { className: "districtItem"}, categorieNewItemSelect);
        let districtNewItemSelect  =  this.createElement('select', { id: 'districtNewItemSelect', className: "districtItemSelect selectItem  js-example-basic-single js-example-placeholder-district"});
        let districtNewItem  =  this.createElement('div', { className: "districtItem"}, districtNewItemSelect);
        
        const modalFiltersContainerItemNew__categorie =  this.createElement('div', { className: 'modalFiltersContainer__categorie'}, categorieNewItem);
        const modalFiltersContainerItemNew__district =  this.createElement('div', { className: 'modalFiltersContainer__district'}, districtNewItem);
        const modalFiltersContainerItemNew =  this.createElement('div', { className: 'modalFiltersContainerItem'}, modalFiltersContainerItemNew__district, modalFiltersContainerItemNew__categorie);
        modalFiltersContainer.appendChild(modalFiltersContainerItemNew);
        this.createWrapperForAddItem(districtNewItemSelect, categorieNewItemSelect)
    },
    createWrapperForAddItem: function(districtNewItemSelect, categorieNewItemSelect){
        let executeQueryDisctict = {
            queryCode: 'cc_FilterDistrict',
            limit: -1,
            parameterValues: []
        };
        this.queryExecutor(executeQueryDisctict, this.createNewFilterDistrict.bind(this, districtNewItemSelect), this);
        this.showPreloader = false;
        
        let executeQueryCategories = {
            queryCode: 'cc_FilterQuestionTypes',
            limit: -1,
            parameterValues: []
        };
        this.queryExecutor(executeQueryCategories, this.createNewFilterCategories.bind( this, categorieNewItemSelect), this);
        this.showPreloader = false;
    },
    /*================== FOR FILTER ===================*/
    createFilterDistrict: function(districtId, districtItemSelect, data){
        data.rows.forEach( function (el){
            let districtItemSelect__option =  this.createElement('option', {innerText: el.values[1], value: el.values[0], className: "districtItemSelect__option"});
            if( districtId == el.values[0] ){
                districtItemSelect__option.selected = true;
            }
            districtItemSelect.appendChild(districtItemSelect__option);
        }.bind(this));
    }, 
    createFilterCategories: function(categorieId, categorieItemSelect, data){
        data.rows.forEach( function (el){
            let categorieItemSelect__option =  this.createElement('option', {innerText: el.values[1], value: el.values[0], className: "districtItemSelect__option"});
            if( categorieId == el.values[0] ){
                categorieItemSelect__option.selected = true;
            }
            categorieItemSelect.appendChild(categorieItemSelect__option);
        }.bind(this));
    }, 
    /*================== FOR ADD FILTER ===================*/
    createNewFilterDistrict: function( districtNewItemSelect, data){
        let districtItemSelect__optionEmpty =  this.createElement('option', { className: "districtItemSelect__option"});
        districtNewItemSelect.appendChild(districtItemSelect__optionEmpty)
        data.rows.forEach( function (el){
            let districtItemSelect__option =  this.createElement('option', {innerText: el.values[1], value: el.values[0], className: "districtItemSelect__option"});
            districtNewItemSelect.appendChild(districtItemSelect__option);
        }.bind(this));
        this.createOptions();
        this.isLoadDistrict = true;
        this.closePreload();
        this.districtId = 0;
        $('#districtNewItemSelect').on('select2:select', function (e) { 
            let districtId = Number(e.params.data.id);
            this.isDistrictFull = true;
            let location = 'district';
            this.addNewItem(location,  districtId);
        }.bind(this));
    },
    createNewFilterCategories: function( categorieNewItemSelect, data){
        let categorieItemSelect__optionEmpty =  this.createElement('option', { className: "districtItemSelect__option"});
        categorieNewItemSelect.appendChild(categorieItemSelect__optionEmpty)
        data.rows.forEach( function (el){
            let categorieItemSelect__option =  this.createElement('option', {innerText: el.values[1], value: el.values[0], className: "districtItemSelect__option"});
            categorieNewItemSelect.appendChild(categorieItemSelect__option);
        }.bind(this));
        this.createOptions();
        this.isLoadCategorie = true;
        this.closePreload();
        this.categorieId = 0;
        $('#categorieNewItemSelect').on('select2:select', function (e) { 
            let categorieId = Number(e.params.data.id);
            this.isCategorieFull = true;
            let location = 'categorie';
            this.addNewItem(location,  categorieId);
        }.bind(this));
    },
    addNewItem: function(location,  id){
        if( location == 'categorie'){
            this.categorieId = id;
        }else if( location = 'district' ){
            this.districtId = id;
        }
        if(this.isCategorieFull &&  this.isDistrictFull){
            this.isCategorieFull = false;
            this.isDistrictFull = false;
            let executeQueryInsertItem = {
                queryCode: 'cc_FilterInsert',
                limit: -1,
                parameterValues: [
                    { key: '@district_id', value:  this.districtId },
                    { key: '@questiondirection_id', value: this.categorieId }    
                ]
            };
            this.queryExecutor(executeQueryInsertItem);
            this.showPreloader = false;
            let filtersBox = document.getElementById('filtersBox');
            let executeQueryFilters = {
                queryCode: 'cc_FilterName',
                limit: -1,
                parameterValues: []
            };
            this.queryExecutor(executeQueryFilters, this.createModalForm.bind(this, filtersBox, 'after'), this);
            this.showPreloader = false;
        }
    },
    closePreload: function(){
        if (this.isLoadDistrict && this.isLoadCategorie) {
            this.messageService.publish(  { name: 'hidePagePreloader'});
        };
    },
    setNewData: function(data){
        this.data = data;
        console.log(this.data);
        this.sendMesOnBtnClick('clickOnСoordinator_table', 'none', 'none');
        this.messageService.publish( { name: 'showPagePreloader'}); 
        this.reloadMainTable();
    },
    createTable: function(reloadTable ,data) {
        for(let i = 2; i < data.columns.length; i ++ ){
            let item = data.columns[i];
            
            let columnHeader =  this.createElement('div', { id: 'columnHeader_'+i+'', code: ''+item.code+'',  className: 'columnHeader', innerText: ''+item.name+''});
            if( i == 2){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_yellow.png)";
            }else if( i == 3){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_green.png)";            
            }else if( i == 4 ){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_blue.png)";                
            }else if( i == 5){
                columnHeader.style.backgroundImage = "url(assets/img/1551/crm1551_purple.png)";
            }else if( i == 6){
                columnHeader.style.backgroundColor = 'rgba(238, 163, 54, 1)';
                columnHeader.style.height = '42px';
                columnHeader.style.marginTop = '2px';
            }
            let column =  this.createElement('div', { id: 'column_'+i+'', code: ''+item.code+'', className: "column"}, columnHeader);
            column.classList.add('column_'+i+'');
            let columnWrapper = this.createElement('div', { id: 'columnWrapper_'+item.code+'',  className: 'columnWrapper'}, column);
            tableContainer.appendChild(columnWrapper);
        }
        
        for(let i = 0; i < 4; i ++  ){
            var elRow = data.rows[i];
            for(let  j = 2; j < elRow.values.length; j ++  ){
                let el = elRow.values[j];
                if( el != 0 ){
                    let columnCategorie__value =  this.createElement('div', { className: 'columnCategorie__value', innerText: '('+el+')'});
                    let columnCategorie__title =  this.createElement('div', { className: 'columnCategorie__title', code: ''+elRow.values[1]+'', innerText: ''+elRow.values[1]+''});
                    let columnCategorie =  this.createElement('div', { className: 'columnCategorie', code: ''+elRow.values[1]+''}, columnCategorie__title, columnCategorie__value);
                    if( j == 2){
                        columnCategorie.classList.add('columnCategorie__yellow');
                    }
                    document.getElementById('column_'+j+'').appendChild(columnCategorie);
                }
            }
        }
        for(let i = 5; i < 6; i++){
            var summaryHeader = data.rows[i];
            for(let  j = 2; j < summaryHeader.values.length; j ++  ){
                let el = summaryHeader.values[j];
                let sub = document.getElementById('column_'+j+'').firstElementChild.innerText;
                document.getElementById('column_'+j+'').firstElementChild.innerText = sub + ' ('+el+') '
            }
        }
        if( reloadTable == true ){
            let categories = document.querySelectorAll('.columnCategorie');
            categories.forEach( el => {
               el.style.display = 'none'; 
            });
            let target = document.getElementById(this.targetId);
            this.showTable(target,  this.column, this.navigation);
        }
        let headers = document.querySelectorAll('.columnHeader');
        
        headers.forEach( function(el){
            el.addEventListener( 'click', function(event){
                let target = event.currentTarget;
                let categories = document.querySelectorAll('.columnCategorie');
                categories.forEach( el => {
                   el.style.display = 'none'; 
                });
                let navigator = 'Усі';
                let column = this.columnName(target);
                this.showTable(target,  column, navigator);
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
                target = target.parentElement.firstElementChild;
                let column = this.columnName(target);
                this.showTable(target, column, navigator);
            }.bind(this));
        }.bind(this));
        
        
        this.messageService.publish( { name: 'hidePagePreloader'});    
    },
    columnName: function(target){
        let column = '';
        if( target.code == "rozyasneno"){
            column = 'Роз`яcнено'
        }else if( target.code == 'neVKompetentsii'){
            column = 'Не в компетенції'
        }else if( target.code == 'doopratsiovani' ){
            column = 'Доопрацьовані'
        }else if( target.code == 'prostrocheni'){
            column = 'Прострочені'
        }else if( target.code == 'neVykonNeMozhl'){
            column = 'План / Програма'
        }
        return column
    },
    showTable: function(target, columnName, navigator){
        const headers = document.querySelectorAll('.columnHeader');
        if( target.classList.contains('check') || target.classList.contains('hover') || target.id == 'searchContainer__input'){
            document.getElementById('columnHeader_2').style.backgroundImage = "url(assets/img/1551/crm1551_yellow.png)"
            document.getElementById('columnHeader_3').style.backgroundImage = "url(assets/img/1551/crm1551_green.png)" 
            document.getElementById('columnHeader_4').style.backgroundImage = "url(assets/img/1551/crm1551_blue.png)"
            document.getElementById('columnHeader_5').style.backgroundImage = "url(assets/img/1551/crm1551_purple.png)"
            document.getElementById('columnHeader_6').style.backgroundColor = "rgb(238, 163, 54)";
            headers.forEach( function(el) {
                el.classList.remove('hover'); 
                el.classList.remove('check'); 
            }.bind(this));
            this.hideAllItems(1)
            this.sendMesOnBtnClick('clickOnСoordinator_table', 'none', 'none');
        }else{
            target.classList.add('hover');
            headers.forEach( function(target, header) {
                let headers = document.querySelectorAll('.columnHeader');
                
                if( target.id != header.id ){
                    if( header.id == headers[4].id ){
                            headers[4].style.backgroundColor = "#d3d3d3";
                            headers[4].style.marginTop = '2px';
                            headers[4].style.height = '42px';
                            headers[4].classList.add('check');
                    }else{
                        header.style.backgroundImage = "url(assets/img/1551/crm1551_disable.png)";
                        header.classList.add('check');
                    }
                }  
            }.bind(this, target));
            this.sendMesOnBtnClick('clickOnСoordinator_table', columnName, navigator, target.id);
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
    sendMesOnBtnClick: function(message, column, navigator, targetId){
        this.messageService.publish({name: message, column: column,  value: navigator, targetId: targetId });
    },
    resultSearch: function(message, value){
        this.messageService.publish({name: message, value: value});
    },
    createOptions: function(selectId, event) {
        $(document).ready(function() {
            $('.js-example-basic-single').select2();
            $(".js-example-placeholder-district").select2({
                placeholder: "Обрати район",
                allowClear: true
            });
            $(".js-example-placeholder-categorie").select2({
                placeholder: "Обрати напрямок робiт",
                allowClear: true
            });
        });
    },    
    destroy: function() {
    }    
};
}());
