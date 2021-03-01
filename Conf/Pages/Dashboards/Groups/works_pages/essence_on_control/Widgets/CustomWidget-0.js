(function() {
    return {
        title: '',
        hint: '',
        formatTitle: function() {},
        customConfig:
                    `
                    <div class='main-buttons-block' id='main-buttons-block'></div>
                    `
        ,
        init() {
            this.sendButtonValues()
            this.subscribers.push(this.messageService.subscribe('UpdateButtonValues', this.updateButtonValues, this));
        },
        sendButtonValues() {
            const getButtonsValues = {
                queryCode: 'essence_group_SelectRows',
                limit: -1,
                parameterValues: [
                ]
            };
            this.queryExecutor(getButtonsValues,this.createButtons,this);
        },
        updateButtonValues() {
            const getButtonsValues = {
                queryCode: 'essence_group_SelectRows',
                limit: -1,
                parameterValues: [
                ]
            };
            this.queryExecutor(getButtonsValues,this.createButtons,this);
        },
        createButtons({rows}) {
            const btnPrimary = document.getElementById('btns-con')
            if(btnPrimary) {
                btnPrimary.remove()
            }
            const questionVal = rows.find(elem=>elem.values.includes('question'))
            const assignmentVal = rows.find(elem=>elem.values.includes('assignment'))
            const eventVal = rows.find(elem=>elem.values.includes('event'))
            const con = this.createElement('div',{className:'btns-con',id:'btns-con'})
            const mainCon = document.getElementById('main-buttons-block')
            const questionBtn = this.createElement('a',{
                className:'btn-primary question',
                id:'question',
                textContent: `Питань: ${questionVal.values[1]}`,
                dataName:'question'
            })
            const assignmentBtn = this.createElement('a',{
                className:'btn-primary assignment',
                id:'assignment',
                textContent: `Доручень: ${assignmentVal.values[1]}`,
                dataName:'assignment'
            })
            const eventBtn = this.createElement('a',{
                className:'btn-primary event',
                id:'event',
                textContent: `Заходів: ${eventVal.values[1]}`,
                dataName:'event'
            })
            con.append(questionBtn,assignmentBtn,eventBtn)
            con.addEventListener('click',this.sendClickData.bind(this))
            mainCon.append(con)
            const title = document.getElementById('title')
            title.remove();
        },
        sendClickData(e) {
            if(e.target.classList.contains('btn-primary')) {
                let msg = {
                    name: 'SetButtonData',
                    package: {
                        value: e.target.dataName
                    }
                };
                this.messageService.publish(msg);
            }
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
        load: function() {
        }
    };
}());
