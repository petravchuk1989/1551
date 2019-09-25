(function () {
  return {
    title: ' ',
    hint: '',
    formatTitle: function() {},
    customConfig:
                `
                <style>
                    #btnsWrapper{
                        display: flex;
                        justify-content: space-around;
                    }
                    .btn, #fileLabel{
                        cursor: pointer;
                        outline: none;
                        color: white;
                        padding: 5px 10px;
                        width: 200px;
                        display: flex;
                        justify-content: center;
                        height: 50px;
                        border: none;
                        align-items: center;
                        text-align: center;
                        position: relative;

                    }
                    input[type="file"] {
                        display: none;
                    }
                    .triangle{
                        width: 0;
                        height: 0;
                        border-style: solid;
                        border-width: 25px 0 25px 21px;
                        position: absolute;
                        right: -21px;
                    }
                    .fileLabel__triangle{
                        border-color: transparent transparent transparent #77e857;
                    }
                    .btnImportFile__triangle{
                        border-color: transparent transparent transparent #58c339;
                    }
                    .showTable__triangle{
                        border-color: transparent transparent transparent #3e9325;
                    }
                    #fileLabel{
                        background-color: #77e857;
                    }
                    #btnImportFile{
                        background-color: #58c339;
                    }
                    #btnShowTable{
                        background-color: #3e9325;
                    }
                    </style>
                <div id='container' ></div>
                `
    ,
    afterViewInit: function() {
        const CONTAINER = document.getElementById('container');
        let fileInput  =  this.createElement('input', { type: 'file', className: 'inputfile', id: 'fileInput', accept: ".csv"});

        let fileLabel__triangle  = this.createElement('div', {className: 'triangle fileLabel__triangle' });
        let fileLabelText = this.createElement('div', { id: 'fileChooserText', className: 'btn', innerText: '1. Обрати файл'});
        let fileLabel = this.createElement('label', { id: 'fileLabel', htmlFor: 'fileInput' }, fileLabelText, fileLabel__triangle);

        let btnImportFile__triangle  = this.createElement('div', {className: 'triangle btnImportFile__triangle' });
        let btnImportFile = this.createElement('div', {disabled: true,  className: 'btn', id: 'btnImportFile',  innerText: '2. Завантажити файл' }, btnImportFile__triangle);
        
        let showTable__triangle  = this.createElement('div', {className: 'triangle showTable__triangle' });
        let btnShowTable = this.createElement('div', { className: 'btn', id: 'btnShowTable',  innerText: '3. Вiдобразити таблицю' },showTable__triangle);

        let btnsWrapper = this.createElement('div', { id: 'btnsWrapper' }, fileInput, fileLabel, btnImportFile, btnShowTable);
        CONTAINER.appendChild(btnsWrapper);

        fileInput.addEventListener('input', event => {
            let target = event.currentTarget;
            if (target.value !== '') { 
                btnImportFile.disabled = false;
             }
        });   
        btnShowTable.addEventListener( 'click', event => {
            this.messageService.publish( { name: 'showTable'});
        });
        
        btnImportFile.addEventListener( 'click', event => {
            let fileInput = document.getElementById('fileInput');
            if(fileInput.files.length > 0){
                this.showPagePreloader("Зачекайте, файл завантажується");
                let files = fileInput.files;
                let target = event.currentTarget;
                let file  = files[0];
                let data = new FormData();
                data.append("file", file);
                data.append("configuration", "{\n   \"HasHeaderRecord\":true,\n   \"EncodingName\":\"windows-1251\",\n   \"Delimiter\":\";\",\n   \"Quote\":\"\\\"\",\n   \"MaxAllowedErrors\":0\n}");
                let xhr = new XMLHttpRequest();
                
                xhr.addEventListener("readystatechange", event => {
                    if (xhr.readyState === 4) {
                        let json = xhr.responseText;
                        let response = JSON.parse(json);
                        let responseNotification = {};
                        if(response.errors.length === 0 ){
                            responseNotification = {
                                title: 'Завантаження пройшло успiшно!',
                                success: 'Завантажено строк: ' + response.success
                            }
                        }else{
                            responseNotification = {
                                title: 'Помилка завантаження!',
                                errorRow: 'Строка: ' + response.errors[0].row,
                                errorColumn: 'Колонка: ' + response.errors[0].column,
                                errorInfo: 'Помилка: ' + response.errors[0].text
                            }
                        }
                        let responseModal =  this.createElement('div', { id: 'responseModal'});
                        this.showModalWindow(responseModal, responseNotification, CONTAINER);                        
                    }
                });
                let url = window.location.origin + '/api/section/demo/import/csv';
                xhr.open("POST", url );
                let token = localStorage.getItem('X-Auth-Token');
                xhr.setRequestHeader("Authorization", 'Bearer ' + token );
                xhr.send(data);
            }
        });

        let labelValue = fileLabel.innerHTML;
        fileInput.addEventListener( 'change', event => {
            let fileName = '';
            if( this.files && this.files.length > 1 ){
                fileName = ( this.getAttribute( 'data-multiple-caption' ) || '' ).replace( '{count}', this.files.length );
            }else{
                fileName = event.target.value.split( '\\' ).pop();
            }
            fileLabel.innerHTML = fileName !== '' ? fileName : labelValue;
            let fileLabel__triangle  = this.createElement('div', {className: 'triangle fileLabel__triangle' });
            fileLabel.appendChild(fileLabel__triangle);
        });
    },
    showModalWindow: function (responseModal, responseNotification, CONTAINER) {
        const modalBtnTrue =  this.createElement('button', { id:'modalBtnTrue', className: 'btn', innerText: 'Сховати'});
        const modalBtnWrapper =  this.createElement('div', { id:'modalBtnWrapper', className: 'modalBtnWrapper'}, modalBtnTrue);
        const contentWrapper =  this.createElement('div', { id:'contentWrapper'}, responseModal);
        const modalTitle =  this.createElement('div', { id:'modalTitle', innerText: 'Результат завантаження:'});
        const modalWindow = this.createElement('div', { id:'modalWindow', className: 'modalWindow'}, modalTitle, contentWrapper ,modalBtnWrapper); 
        const modalWindowWrapper = this.createElement('div', { id:'modalWindowWrapper', className: 'modalWindowWrapper'}, modalWindow); 

        modalBtnTrue.addEventListener( 'click', event => {
            CONTAINER.removeChild(container.lastElementChild);
        });
        for (key in responseNotification) {
            if( key === 'title'){ 
                let responseTitle =  this.createElement('div', { id: 'responseTitle', className: 'responseTest', innerText: responseNotification[key] });
                responseModal.appendChild(responseTitle); 
            }else if(key === 'errorInfo'){
                let responseErrorInfo =  this.createElement('div', { id: 'responseErrorInfo', className: 'responseTest', innerText:responseNotification[key] });
                responseModal.appendChild(responseErrorInfo);
            }else if(key === 'errorRow'){
                let responseErrorRow =  this.createElement('div', { id: 'responseErrorRow', className: 'responseError responseTest', innerText: responseNotification[key] });
                responseModal.appendChild(responseErrorRow);
            }else if(key === 'errorColumn'){
                let responseErrorColumn =  this.createElement('div', { id: 'responseErrorColumn', className: 'responseError responseTest', innerText: responseNotification[key] });
                responseModal.appendChild(responseErrorColumn);
            }
        }
        this.hidePagePreloader();
        CONTAINER.appendChild(modalWindowWrapper);
    },
    createElement: function(tag, props, ...children){
        const element = document.createElement(tag);
        Object.keys(props).forEach( key => element[key] = props[key] );
        if(children.length > 0){
            children.forEach( child =>{
                element.appendChild(child);
            });
        } return element;
    }     
};
}());
