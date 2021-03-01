(function() {
    return {
        title: ' ',
        hint: '',
        formatTitle: function() {},
        customConfig:
                `
                <div id='container' class='btn-wrapper'></div>
                `
        ,
        async init() {
            this.subscribers.push(this.messageService.subscribe('GlobalFilterChanged', this.setFiltersValue, this));
            this.executeQueryShowUserFilterGroups();
            this.FiltersPackageHelperWithoutTimePosition = await import('/modules/Helpers/Filters/FiltersPackageHelperWithoutTimePosition.js');
        },
        afterViewInit: function() {
            this.sub = this.messageService.subscribe('setData', this.setData, this);
            this.counter = 0
            const CONTAINER = document.getElementById('container');
            let iconReturn = this.createElement('i', { className: 'dx-icon dx-icon-home' });
            let btnReturn = this.createElement('button', { id: 'btnReturn',className:'btnReturn', innerText: 'Повернуться до фільтрації'});
            btnReturn.prepend(iconReturn)
            let btnWrap = this.createElement('div', { className: 'btnWrap' }, btnReturn);
            let iconSave = this.createElement('i', { className: 'dx-icon dx-icon-save' });
            let btnSaveInCons = this.createElement('button', {
                className:'btnReturn', id: 'btnSaveInCons', innerText: 'Зберегти'});
            btnSaveInCons.prepend(iconSave)
            let btnSaveInConsWrap = this.createElement('div', { className: 'btnWrap' }, btnSaveInCons);
            let iconFilters = this.createElement('i', { className: 'dx-icon dx-icon-detailslayout' });
            let btnSavedFilters = this.createElement('button', {className:'btnReturn',
                id: 'btnSavedFilters', innerText: 'Список'});
            btnSavedFilters.prepend(iconFilters)
            let btnSavedFiltersWrap = this.createElement('div', { className: 'btnWrap' }, btnSavedFilters);
            const conForBtns = this.createElement('div', { className: 'conForBtns' }, btnSaveInConsWrap,btnSavedFiltersWrap);
            CONTAINER.appendChild(conForBtns);
            CONTAINER.appendChild(btnWrap);
            btnReturn.addEventListener('click', () => {
                document.getElementById('summary__table').style.display = 'none';
                document.getElementById('content').style.display = 'block';
                document.getElementById('savedFiltersCon').style.display = 'block';
            });
            btnSaveInCons.addEventListener('click',this.showModalName.bind(this));
            btnSavedFilters.addEventListener('click',this.showModalSavedFilters.bind(this));
        },
        setFiltersValue(message) {
            const filters = message.package.value.values;
            this.selectedFilters = filters.filter(elem=>elem.active === true)
        },
        showModalName() {
            const con = document.getElementById('container');
            const modal = `<div id="modalWindowWrapper" class="modalWindowWrapper"">
                                <div id="modalWindow" class="modalWindow">
                                    <div id="modalBtnWrapper" class="modalBtnWrapper">
                                        <button id="modalBtnSave" class="btn">Зберегти</button>
                                        <button id="modalBtnExit" class="btn">Вийти</button>
                                    </div>
                                <input id="newFilterNameInput" placeholder="Внесіть назву">
                                </div>
                            </div>`
            con.insertAdjacentHTML('beforeend',modal)
            this.addListenersOnModal()
        },
        showModalSavedFilters() {
            const con = document.getElementById('container');
            const gridded = this.userFilterGroups.filter(elem=>Array.isArray(elem.filters))
            const grid = gridded.map(elem=>{
                const insideGrid = elem.filters.map(item=>`<div class="userFilter">${item.displayValue}</div>`).join('')
                return `<div class='userFilterGroup' id=groupId${elem.id} data-id=${elem.id}>
                    <div class='groupHeader' id='groupHeader'>
                        <div class="displayBtn groupBtn fa fa-arrow-down"></div>
                        <input class="userFilterGroupName" disabled="true" value=${elem.name}>
                        <div class="groupEditBtn groupBtn fa fa-arrow-right"></div>
                        <div class="groupEditBtn groupBtn fa fa-edit"></div>
                        <div class="groupDeleteBtn groupBtn fa fa-trash"></div>
                    </div>
                    <div class='userFiltersListWrapper41'>
                        ${insideGrid}
                    </div>
                </div>`
            }).join('')
            const modal = `<div id="modalWindowWrapper" class="modalWindowWrapper"">
                                <div id="modalWindow" class="modalWindow">
                                    <div id="modalBtnWrapper" class="modalBtnWrapper">
                                        <button id="modalBtnExit" class="btn">Вийти</button>
                                    </div>
                                    <div class="userFilterGroupsWrapper">
                                        ${grid}
                                    </div> 
                                </div>
                            </div>`
            con.insertAdjacentHTML('beforeend',modal)
            this.addListenersOnModal()
        },
        addListenersOnModal() {
            const groupHeader = document.querySelectorAll('#groupHeader');
            if(groupHeader) {
                groupHeader.forEach(elem=>elem.addEventListener('click',this.modalListeners.bind(this)))
            }
            const modalBtnSave = document.getElementById('modalBtnSave');
            if(modalBtnSave) {
                modalBtnSave.addEventListener('click',this.saveNewFiltersGroup.bind(this))
            }
            const modalBtnExit = document.getElementById('modalBtnExit');
            modalBtnExit.addEventListener('click',this.removeModalSave)
        },
        modalListeners(e) {
            const con = e.target.closest('.userFilterGroup')
            if (e.target.classList.contains('fa-arrow-down')) {
                e.target.classList.remove('fa-arrow-down')
                e.target.classList.add('fa-arrow-up')
                const div = con.querySelector('.userFiltersListWrapper41')
                div.classList.add('active')
            } else if(e.target.classList.contains('fa-arrow-right')) {
                this.restoreFilters(con.getAttribute('data-id'))
            } else if(e.target.classList.contains('fa-edit')) {
                const input = con.querySelector('.userFilterGroupName')
                input.removeAttribute('disabled')
                input.addEventListener('keydown',(event) =>{
                    if (event.code === 'Enter') {
                        const val = input.value
                        let executeQuery = {
                            queryCode: 'ConstructorFilters_UName',
                            limit: -1,
                            parameterValues: [
                                { key: '@Id', value: con.getAttribute('data-id') },
                                { key: '@filter_name', value: val }
                            ]
                        };
                        this.queryExecutor(executeQuery, this, this);
                        input.disabled = 'true'
                    }
                })
            } else if(e.target.classList.contains('fa-trash')) {
                let executeQuery = {
                    queryCode: 'ConstructorFilters_DRow',
                    limit: -1,
                    parameterValues: [
                        { key: '@Id', value: con.getAttribute('data-id') }
                    ]
                };
                this.queryExecutor(executeQuery, this, this);
                con.remove()
            } else if(e.target.classList.contains('fa-arrow-up')) {
                e.target.classList.add('fa-arrow-down')
                e.target.classList.remove('fa-arrow-up')
                const div = con.querySelector('.userFiltersListWrapper41')
                div.classList.remove('active')
            }
        },
        restoreFilters: function(id) {
            this.setGlobalFilterPanelVisibility(true);
            const filters = this.userFilterGroups.find(f => f.id === +id).filters;
            const FiltersPackageHelper = new this.FiltersPackageHelperWithoutTimePosition.FiltersPackageHelperWithoutTimePosition();
            const filtersPackage = FiltersPackageHelper.getFiltersPackage(filters);
            this.clearAllFilter();
            this.applyFilters(filtersPackage);
            this.removeModalSave();
        },
        setGlobalFilterPanelVisibility: function(state) {
            const msg = {
                name: 'SetFilterPanelState',
                package: {
                    value: state
                }
            };
            this.messageService.publish(msg);
        },
        removeModalSave() {
            const modal = document.getElementById('modalWindowWrapper')
            modal.remove()
        },
        saveNewFiltersGroup: function() {
            const name = document.getElementById('newFilterNameInput').value;
            if (name !== '') {
                const filterJson = JSON.stringify(this.getFiltersGroupPackage());
                this.executeSaveFilterGroup(name, filterJson);
            }
        },
        executeSaveFilterGroup(name, filterJson) {
            let executeQuery = {
                queryCode: 'ConstructorFilters_IRow',
                limit: -1,
                parameterValues: [
                    { key: '@filter_name', value: name },
                    { key: '@filters', value: filterJson }
                ]
            };
            this.queryExecutor(executeQuery, this.afterAddFilterGroup, this);
        },
        afterAddFilterGroup: function() {
            this.removeModalSave()
            this.executeQueryShowUserFilterGroups();
        },
        getFiltersGroupPackage: function() {
            const filterPackage = [];
            this.selectedFilters.forEach(filter => {
                filterPackage.push({
                    value: filter.value.viewValue ? filter.value.value : filter.value,
                    type: filter.type,
                    placeholder: filter.placeholder,
                    viewValue: filter.type.includes('Date') ? null : filter.value.viewValue,
                    name: filter.name,
                    timePosition: filter.timePosition
                });
            });
            debugger
            return filterPackage;
        },
        setFilterViewValues: function(filter) {
            return `${filter.value.viewValue}`;
        },
        getSelectFilterViewValuesObject(filter) {
            const obj = {}
            switch (filter.operation) {
                case true:
                case '=':
                    obj.title = filter.placeholder;
                    obj.value = 'Наявнiсть'
                    break;
                case 'like':
                    obj.title = filter.placeholder;
                    obj.value = filter.value
                    break;
                case '===':
                case '==':
                case 'in':
                case '+""+':
                    obj.title = filter.placeholder;
                    obj.value = filter.viewValue
                    break
                default:
                    obj.title = this.operation(filter.operation, filter.placeholder);
                    obj.value = this.changeDateValue(filter.value);
                    break;
            }
            return obj;
        },
        operation: function(operation, title) {
            let result = title;
            switch (operation) {
                case '>=':
                    result = title + ' з'
                    break;
                case '<=':
                    result = title + ' по'
                    break;
                default:
                    break;
            }
            return result;
        },
        changeDateValue: function(date) {
            let dd = date.getDate().toString();
            let mm = (date.getMonth() + 1).toString();
            let yyyy = date.getFullYear().toString();
            dd = dd.length === 1 ? '0' + dd : dd;
            mm = mm.length === 1 ? '0' + mm : mm;
            return `${dd}-${mm}-${yyyy}`;
        },
        executeQueryShowUserFilterGroups: function() {
            let executeQuery = {
                queryCode: 'ConstructorFilters_SRows',
                limit: -1,
                parameterValues: [
                    { key: '@pageOffsetRows', value: 0 },
                    { key: '@pageLimitRows', value: 50 }
                ]
            };
            this.queryExecutor(executeQuery, this.setUserFilterGroups, this);
            this.showPreloader = false;
        },
        setUserFilterGroups: function(groups) {
            this.userFilterGroups = [];
            groups.rows.forEach(group => {
                const indexOfId = 0;
                const indexOfName = 1;
                const indexOfFilters = 2;
                this.userFilterGroups.push({
                    id: group.values[indexOfId],
                    name: group.values[indexOfName],
                    filters: JSON.parse(group.values[indexOfFilters])
                });
            });
            this.sendFilterGroup(this.userFilterGroups)
        },
        sendFilterGroup(arr) {
            this.messageService.publish({ name: 'sendFilter', value: arr });
        },
        createElement: function(tag, props, ...children) {
            const element = document.createElement(tag);
            Object.keys(props).forEach(key => element[key] = props[key]);
            if(children.length > 0) {
                children.forEach(child =>{
                    element.appendChild(child);
                });
            } return element;
        }
    };
}());
