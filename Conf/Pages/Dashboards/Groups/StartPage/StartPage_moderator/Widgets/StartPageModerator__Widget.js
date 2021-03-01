(function() {
    return {
        customConfig:
                `
                    <div id='container'>
                        <div class='header-label' id='header-label'>
                            Сторінка модератора
                        </div>
                    </div>
                `
        ,
        init: function() {
            let executeQuery = {
                queryCode: 'GetReceiptSources',
                limit: -1,
                parameterValues: []
            };
            this.queryExecutor(executeQuery, this.load, this);
            this.showPreloader = false;
            this.getHeaderInfo()
        },
        showTypesList: function(data) {
            const modalBtnTrue = this.createElement('button', { id:'modalBtnTrue', className: 'btn', innerText: 'Закрити'});
            const modalBtnWrapper = this.createElement('div', { id:'modalBtnWrapper' }, modalBtnTrue);
            const listItems = this.createElement('div', { id:'listItems' });
            data.rows.forEach(el => {
                let listItem = this.createElement('div', { className: 'listItem', innerText: el.values[1], type: el.values[0] });
                listItems.appendChild(listItem);
                listItem.addEventListener('click', event => {
                    let target = event.currentTarget;
                    let phoneNumber = document.getElementById('listPhoneNumberInput').value;
                    window.open(
                        location.origin +
                        localStorage.getItem('VirtualPath') +
                        '/sections/CreateAppeal/add?phone=' + phoneNumber +
                        '&type=' + target.type +
                        '&sipcallid=0'
                    );
                });
            });
            const listTitle = this.createElement('div', { id:'listTitle', innerText: 'Виберіть тип звернення:' });
            const listPhoneNumberInput = this.createElement('input', { id:'listPhoneNumberInput', placeholder: 'Введiть номер телефону' });
            const listWrapper = this.createElement('div', { id:'listWrapper' }, listTitle, listPhoneNumberInput, listItems);
            const modalWindow = this.createElement('div', { id:'modalWindow', className: 'modalWindow'}, listWrapper, modalBtnWrapper);
            const modalWindowWrapper = this.createElement('div', { id:'modalWindowWrapper', className: 'modalWindowWrapper'}, modalWindow);
            this.container.appendChild(modalWindowWrapper);
            modalBtnTrue.addEventListener('click', () => {
                const lastElementChild = this.container.lastElementChild
                this.container.removeChild(lastElementChild);
            });
        },
        getHeaderInfo() {
            let executeQuery = {
                queryCode: 'db_StartMod_Main',
                limit: -1,
                parameterValues: []
            };
            this.queryExecutor(executeQuery, this.createHeader, this);
        },
        createHeader({columns,rows}) {
            const con = this.createElement('div',{className:'header-con'})
            const onModerationIndex = columns.findIndex(elem=>elem.code === 'on_moderation')
            const mutchHoursIndex = columns.findIndex(elem=>elem.code === 'mutch_2hours')
            const oldestIndex = columns.findIndex(elem=>elem.code === 'oldest')
            const appealIdIndex = columns.findIndex(elem=>elem.code === 'appeal_id')
            const dataToConvert = new Date(rows[0].values[oldestIndex])
            const data = this.changeDateValue(dataToConvert)
            this.appealId = rows[0].values[appealIdIndex]
            const grid = `<div class='header-info'>
                            <p class='header-text'>На модерації: <span class='header-value'>${rows[0].values[onModerationIndex]}</span></p>
                            </div>
                            <div class='header-info'>
                        <p class='header-text'>&#10095 2 годин: <span class='header-value'>${rows[0].values[mutchHoursIndex]}</span></p>
                            </div>
                            <div class='header-info'>
                        <p class='header-text'>Найстаріше: <span class='header-value'>${data}</span></p>
                            </div>`;
            con.insertAdjacentHTML('beforeend',grid)
            const label = document.getElementById('header-label')
            label.after(con)
        },
        toUTC(val) {
            let date = new Date(val);
            let year = date.getFullYear();
            let monthFrom = date.getMonth();
            let dayTo = date.getDate();
            let hh = date.getHours();
            let mm = date.getMinutes();
            let dateTo = `${year}, ${monthFrom} , ${dayTo}, ${hh + 3}, ${mm}`
            return dateTo
        },
        changeDateValue: function(date) {
            let dd = date.getDate().toString();
            let monthFrom = (date.getMonth() + 1).toString();
            let yyyy = date.getFullYear().toString();
            let hh = date.getHours().toString();
            let mm = date.getMinutes().toString();
            let ss = date.getSeconds().toString();
            dd = dd.length === 1 ? '0' + dd : dd;
            hh = hh.length === 1 ? '0' + hh : hh;
            mm = mm.length === 1 ? '0' + mm : mm;
            ss = ss.length === 1 ? '0' + ss : ss;
            monthFrom = monthFrom.length === 1 ? '0' + monthFrom : monthFrom;
            return `${dd}-${monthFrom}-${yyyy} ${hh}:${mm}:${ss}`;
        },
        load: function(data) {
            this.container = document.getElementById('container');

            let conFirst = this.createElement('div',{className:'first-con'})
            let nextAppeal__icon = this.createElement('div',
                {
                    className: 'icon letterIcon material-icons',
                    innerText: 'forward'
                }
            );
            let nextAppeal__description = this.createElement('div',
                {
                    className: 'description',
                    innerText: 'Наступне звернення'
                }
            );
            nextAppeal__icon.style.color = '#f44336';
            let nextAppeal__borderBottom = this.createElement('div', { className: 'border-bottom' });
            let nextAppeal__borderRight = this.createElement('div', { className: 'border-right'});
            let nextAppeal = this.createElement('div',
                {
                    className: 'group first',
                    tabindex: '0'
                },
                nextAppeal__icon, nextAppeal__description, nextAppeal__borderBottom,nextAppeal__borderRight
            );
            nextAppeal.addEventListener('click', () => {
                const appeal_id = this.appealId
                if(appeal_id) {
                    const buttonQuery = {
                        queryCode: 'db_StartMod_ButtonNextAppeal',
                        limit: -1,
                        parameterValues: [
                            { key: '@Id', value: appeal_id }
                        ]
                    };
                    this.queryExecutor(buttonQuery, this.getButtonQuery, this);
                    window.open(location.origin + localStorage.getItem('VirtualPath') + '/sections/Appeals_from_Site/edit/' + appeal_id);
                }
            });
            conFirst.append(nextAppeal)

            let moderatorStatistic__icon = this.createElement('div',
                {
                    className: 'icon letterIcon material-icons',
                    innerText: 'contact_phone'
                }
            );
            let moderatorStatistic__description = this.createElement('div',
                {
                    className: 'description',
                    innerText: 'Статистика модератора'
                }
            );
            moderatorStatistic__icon.style.color = '#f44336';
            let moderatorStatistic__borderBottom = this.createElement('div', { className: 'border-bottom' });
            let moderatorStatistic__borderRight = this.createElement('div', { className: 'border-right'});
            let moderatorStatistic = this.createElement('div',
                {
                    className: 'group',
                    tabindex: '0'
                },
                moderatorStatistic__icon, moderatorStatistic__description, moderatorStatistic__borderBottom,moderatorStatistic__borderRight
            );
            /*moderatorStatistic.addEventListener('click', () => {
                this.showModalWindow();
            });*/

            let groupRegByPhone__icon = this.createElement('div',
                {
                    className: 'icon letterIcon material-icons',
                    innerText: 'contact_phone'
                }
            );
            let groupRegByPhone__description = this.createElement('div',
                {
                    className: 'description',
                    innerText: 'Реєстрація Звернення за дзвінком'
                }
            );
            groupRegByPhone__icon.style.color = '#f44336';
            let groupRegByPhone__borderBottom = this.createElement('div', { className: 'border-bottom' });
            let groupRegByPhone__borderRight = this.createElement('div', { className: 'border-right'});
            let groupRegByPhone = this.createElement('div',
                {
                    className: 'group',
                    tabindex: '0'
                },
                groupRegByPhone__icon, groupRegByPhone__description, groupRegByPhone__borderBottom, groupRegByPhone__borderRight
            );
            groupRegByPhone.addEventListener('click', () => {
                this.showModalWindow();
            });

            let groupSearchTable__icon = this.createElement('div',
                {
                    className: 'icon letterIcon material-icons',
                    innerText: 'find_in_page'
                }
            );
            let groupSearchTable__description = this.createElement('div', { className: 'description', innerText: 'Розширений пошук'});
            groupSearchTable__icon.style.color = '#2196F3';
            let groupSearchTable__borderBottom = this.createElement('div', { className: 'border-bottom' });
            let groupSearchTable__borderRight = this.createElement('div', { className: 'border-right'});
            let groupSearchTable = this.createElement('div',
                {
                    className: 'group',
                    tabindex: '0'
                },
                groupSearchTable__icon, groupSearchTable__description, groupSearchTable__borderBottom, groupSearchTable__borderRight
            );
            groupSearchTable.addEventListener('click', () => {
                window.open(location.origin + localStorage.getItem('VirtualPath') + '/dashboard/page/poshuk_table');
            });

            let groupLetter__icon = this.createElement('div', { className: 'icon letterIcon material-icons', innerText: 'mail' });
            let groupLetter__description = this.createElement('div',
                {
                    className: 'description',
                    innerText: 'Реєстрація Звернення згідно листа'
                }
            );
            groupLetter__icon.style.color = '#6ec6ff';
            let groupLetter__borderBottom = this.createElement('div', { className: 'border-bottom' });
            let groupLetter__borderRight = this.createElement('div', { className: 'border-right'});
            let groupLetter = this.createElement('div',
                {
                    className: 'group',
                    tabindex: '0'
                },
                groupLetter__icon, groupLetter__description, groupLetter__borderBottom, groupLetter__borderRight
            );
            groupLetter.addEventListener('click', () => {
                this.showTypesList(data);
            });

            let appealSearch__icon = this.createElement('div', { className: 'icon letterIcon material-icons', innerText: 'mail' });
            let appealSearch__description = this.createElement('div',
                {
                    className: 'description',
                    innerText: 'Пошук звернень'
                }
            );
            appealSearch__icon.style.color = '#6ec6ff';
            let appealSearch__borderBottom = this.createElement('div', { className: 'border-bottom' });
            let appealSearch__borderRight = this.createElement('div', { className: 'border-right'});
            let appealSearch = this.createElement('div',
                {
                    className: 'group',
                    tabindex: '0'
                },
                appealSearch__icon, appealSearch__description, appealSearch__borderBottom, appealSearch__borderRight
            );
            appealSearch.addEventListener('click', () => {
                window.open(location.origin + localStorage.getItem('VirtualPath') + '/sections/Appeals');
            });

            let groupsWrapper = this.createElement('div',
                {
                    className: 'group-btns'
                },
                conFirst, moderatorStatistic,groupSearchTable,appealSearch, groupRegByPhone, groupLetter
            );
            this.container.appendChild(groupsWrapper);
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
        showModalWindow: function() {
            const modalBtnClose = this.createElement('button', { id:'modalBtnClose', className: 'btn', innerText: 'Закрити'});
            const modalBtnTrue = this.createElement('button', { id:'modalBtnTrue', className: 'btn', innerText: 'Підтвердити'});
            const modalBtnWrapper = this.createElement('div', { id:'modalBtnWrapper' }, modalBtnTrue, modalBtnClose);
            const modalNumber = this.createElement('input',
                {
                    id:'modalNumber',
                    type:'text',
                    placeholder:'Введіть номер телефону в форматі 0xxxxxxxxx',
                    value: ''
                }
            );
            const modalWindow = this.createElement('div', { id:'modalWindow', className: 'modalWindow'}, modalNumber, modalBtnWrapper);
            const modalWindowWrapper = this.createElement('div', { id:'modalWindowWrapper', className: 'modalWindowWrapper'}, modalWindow);
            this.container.appendChild(modalWindowWrapper);
            modalBtnTrue.addEventListener('click', () => {
                let number = modalNumber.value;
                window.open(
                    location.origin +
                    localStorage.getItem('VirtualPath') +
                    '/sections/CreateAppeal/add?phone=' + number +
                    '&type=1&sipcallid=0'
                );
                const lastElementChild = this.container.lastElementChild;
                this.container.removeChild(lastElementChild);
            });
            modalBtnClose.addEventListener('click', () => {
                const lastElementChild = this.container.lastElementChild;
                this.container.removeChild(lastElementChild);
            });
        }
    };
}());
