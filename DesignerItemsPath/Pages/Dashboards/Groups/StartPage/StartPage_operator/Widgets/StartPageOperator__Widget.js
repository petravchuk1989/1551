(function () {
  return {
    // title: '',
    // hint: '',
    // formatTitle: function() {},
    customConfig:
                `
              <style>
                  
              </style>
                
              <div id='container'></div>  
                
                `
  ,
  afterViewInit: function() {
      const CONTAINER = document.getElementById('container');
      let title = this.createElement('div', { className: 'header-label', innerText: 'КБУ "Контактний центр міста Києва 1551"'});

      let groupRegByPhone__icon = this.createElement('div', { className: "icon letterIcon material-icons",  innerText: 'contact_phone' });
      let groupRegByPhone__description = this.createElement('div', { className: "description", innerText: 'Реєстрація Звернення за дзвінком'});
      groupRegByPhone__icon.style.color = '#f44336';
      let groupRegByPhone__borderBottom = this.createElement('div', { className: "border-bottom" });
      let groupRegByPhone__borderRight = this.createElement('div', { className: "border-right"});
      let groupRegByPhone = this.createElement('div', { className: "group", tabindex: '0' }, groupRegByPhone__icon, groupRegByPhone__description, groupRegByPhone__borderBottom, groupRegByPhone__borderRight );
      groupRegByPhone.addEventListener('click',  event => { 
          this.showModalWindow();
      });

      let groupViewAppeals__icon = this.createElement('div', { className: "icon letterIcon material-icons",  innerText: 'view_list' });
      let groupViewAppeals__description = this.createElement('div', { className: "description", innerText: 'Перегляд Звернень з сайту'});
      groupViewAppeals__icon.style.color = '#ff7961';
      let groupViewAppeals__borderBottom = this.createElement('div', { className: "border-bottom" });
      let groupViewAppeals__borderRight = this.createElement('div', { className: "border-right"});
      let groupViewAppeals = this.createElement('div', { className: "group", tabindex: '0' }, groupViewAppeals__icon, groupViewAppeals__description, groupViewAppeals__borderBottom, groupViewAppeals__borderRight );
      groupViewAppeals.addEventListener('click',  event => { 
          window.open(location.origin + localStorage.getItem('VirtualPath')+'/dashboard/page/Appeals_from_Site');
      });
      
      let groupRegAppeals__icon = this.createElement('div', { className: "icon letterIcon material-icons",  innerText: 'desktop_windows' });
      let groupRegAppeals__description = this.createElement('div', { className: "description", innerText: 'Реєстрація Звернень з сайту'});
      groupRegAppeals__icon.style.color = '#2196F3';
      let groupRegAppeals__borderBottom = this.createElement('div', { className: "border-bottom" });
      let groupRegAppeals__borderRight = this.createElement('div', { className: "border-right"});
      let groupRegAppeals = this.createElement('div', { className: "group", tabindex: '0' }, groupRegAppeals__icon, groupRegAppeals__description, groupRegAppeals__borderBottom, groupRegAppeals__borderRight );
      groupRegAppeals.addEventListener('click',  event => { 
          window.open(location.origin + localStorage.getItem('VirtualPath')+'/dashboard/page/referrals_from_the_site');
      });

      let groupSearchTable__icon = this.createElement('div', { className: "icon letterIcon material-icons",  innerText: 'find_in_page' });
      let groupSearchTable__description = this.createElement('div', { className: "description", innerText: 'Розширений пошук'});
      groupSearchTable__icon.style.color = '#2196F3';
      let groupSearchTable__borderBottom = this.createElement('div', { className: "border-bottom" });
      let groupSearchTable__borderRight = this.createElement('div', { className: "border-right"});
      let groupSearchTable = this.createElement('div', { className: "group", tabindex: '0' }, groupSearchTable__icon, groupSearchTable__description, groupSearchTable__borderBottom, groupSearchTable__borderRight );
      groupSearchTable.addEventListener('click',  event => { 
          window.open(location.origin + localStorage.getItem('VirtualPath')+'/dashboard/page/poshuk_table');
      });
      
      let groupCall__icon = this.createElement('div', { className: "icon letterIcon material-icons",  innerText: 'perm_phone_msg' });
      let groupCall__description = this.createElement('div', { className: "description", innerText: 'Прозвон'});
      groupCall__icon.style.color = '#2196F3';
      let groupCall__borderBottom = this.createElement('div', { className: "border-bottom" });
      let groupCall__borderRight = this.createElement('div', { className: "border-right"});
      let groupCall = this.createElement('div', { className: "group", tabindex: '0' }, groupCall__icon, groupCall__description, groupCall__borderBottom, groupCall__borderRight );
      groupCall.addEventListener('click',  event => { 
          window.open(location.origin + localStorage.getItem('VirtualPath')+'/dashboard/page/prozvon');
      });

      let groupLetter__icon = this.createElement('div', { className: "icon letterIcon material-icons",  innerText: 'mail' });
      let groupLetter__description = this.createElement('div', { className: "description", innerText: 'Реєстрація Звернення згідно листа'});
      groupLetter__icon.style.color = '#6ec6ff';
      let groupLetter__borderBottom = this.createElement('div', { className: "border-bottom" });
      let groupLetter__borderRight = this.createElement('div', { className: "border-right"});
      let groupLetter = this.createElement('div', { className: "group", tabindex: '0' }, groupLetter__icon, groupLetter__description, groupLetter__borderBottom, groupLetter__borderRight );
      groupLetter.addEventListener('click',  event => { 
          /* window.open(location.origin + localStorage.getItem('VirtualPath')+'/dashboard/page/.......................'); */
      });
      
      let groupsWrapper = this.createElement('div', { className: 'group-btns' }, groupRegByPhone, groupViewAppeals, groupRegAppeals, groupSearchTable, groupCall, groupLetter );
      CONTAINER.appendChild(title);
      CONTAINER.appendChild(groupsWrapper);
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
  showModalWindow: function(message) {
      let CONTAINER = document.getElementById('container');
      
      const modalBtnClose =  this.createElement('button', { id:'modalBtnClose', className: 'btn', innerText: 'Закрити'});
      const modalBtnTrue =  this.createElement('button', { id:'modalBtnTrue', className: 'btn', innerText: 'Підтвердити'});
      const modalBtnWrapper =  this.createElement('div', { id:'modalBtnWrapper' }, modalBtnTrue, modalBtnClose);
      const modalNumber =  this.createElement('input', { id:'modalNumber', type:"text", placeholder:"Введіть номер телефону в форматі 0xxxxxxxxx",  value: ""});
      const modalWindow = this.createElement('div', { id:'modalWindow', className: 'modalWindow'}, modalNumber, modalBtnWrapper); 
      const modalWindowWrapper = this.createElement('div', { id:'modalWindowWrapper', className: 'modalWindowWrapper'}, modalWindow); 
      CONTAINER.appendChild(modalWindowWrapper);
      
      modalBtnTrue.addEventListener( 'click', event => {
          let target = event.currentTarget;
          let number = modalNumber.value
          console.log(number);
          window.open(location.origin + localStorage.getItem('VirtualPath') + "/sections/CreateAppeal/add?phone="+number+"&type=1");
          CONTAINER.removeChild(container.lastElementChild);
      });
      modalBtnClose.addEventListener( 'click', event => {
          let target = event.currentTarget;
          CONTAINER.removeChild(container.lastElementChild);
      });
  }, 
};
}());
