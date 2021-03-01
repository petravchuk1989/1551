(function() {
    return {
        title: ' ',
        hint: '',
        formatTitle: function() {},
        customConfig:
                `
                <div id='savedFiltersCon' ></div>
                `
        ,
       init:async function() {
            const con = document.getElementById('savedFiltersCon')
            document.getElementById('content').append(con)
            this.sub3 = this.messageService.subscribe('showTable', this.showTable, this);
            this.sub4 = this.messageService.subscribe('sendFilter', this.executeQueryShowUserFilterGroups, this);
            this.executeQueryShowUserFilterGroups()
            this.FiltersPackageHelperWithoutTimePosition = await import('/modules/Helpers/Filters/FiltersPackageHelperWithoutTimePosition.js');
        },
        afterViewInit: function() {
        },
        getFilters(arr) {
         return this.userFilterGroups = arr;
        },
        showTable: function(message) {
            if(message.value === 'filter') {
                document.getElementById('NativeDataGridWidget-0').style.display = 'none';
            }
        },
        showModalSavedFilters() {
            const con = document.getElementById('savedFiltersCon');
            const newGrid = document.getElementById('widgetFiltersInfo');
            if(newGrid) {
                newGrid.remove()
            }
            const gridded = this.userFilterGroups.filter(elem=>Array.isArray(elem.filters))
            const grid = gridded.map(elem=>{
                const insideGrid = elem.filters.map(item=>`<div class="userFilter">${item.displayValue}</div>`).join('')
                return `<div class='userFilterGroup' id=groupId${elem.id} data-id=${elem.id}>
                    <div class='groupHeader' id='groupHeader2'>
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
            const widgetGrig = `<div id='widgetFiltersInfo'>
                                    <div id="modalWindow2" class="modalWindow">
                                        <div class="userFilterGroupsWrapper">
                                            ${grid}
                                        </div> 
                                    </div>
                                </div>
                            `
            con.insertAdjacentHTML('beforeend',widgetGrig)
            this.addListenersOnModal()
        },
        addListenersOnModal() {
            const groupHeader = document.querySelectorAll('#groupHeader2');
            if(groupHeader) {
                groupHeader.forEach(elem=>elem.addEventListener('click',this.modalListeners.bind(this)))
            }
        },
        modalListeners(e) {
            const con = e.target.closest('.userFilterGroup')
            if(e.target.classList.contains('fa-arrow-right')) {
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
                        this.queryExecutor(executeQuery, this.executeQueryShowUserFilterGroups, this);
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
                this.queryExecutor(executeQuery, this.executeQueryShowUserFilterGroups, this);
                con.remove()
            }
        },
        restoreFilters: function(id) {
            this.setGlobalFilterPanelVisibility(true);
            const filters = this.userFilterGroups.find(f => f.id === +id).filters;
            const FiltersPackageHelper = new this.FiltersPackageHelperWithoutTimePosition.FiltersPackageHelperWithoutTimePosition();
            const filtersPackage = FiltersPackageHelper.getFiltersPackage(filters);
            this.clearAllFilter();
            this.applyFilters(filtersPackage);
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
            this.showModalSavedFilters()
        }
    };
}());
