(function() {
    return {
        Labels: {
            Title: [],
            Description: [],
            DescriptionWithoutExecutor: [],
            Text: [],
            TextWithoutExecutor: [],
            TextWithoutPlanDate: [],
            TextWithoutExecutor_PlanDate: [],
        },
        init: function() {

            if (this.state === 'create') {
                this.form.setControlValue('IsActive', true);
            };

            this.form.disableControl('Action');

            let dependParams = [{ parameterCode: '@ServiceTypeId', parameterValue: this.form.getControlValue('ServiceTypeId') }];
            this.form.setControlParameterValues('ClaimTypeId', dependParams);

            const GetActionNameById = {
                queryCode: 'SN_GetActionNameById',
                parameterValues: [{key: '@Id', value: this.form.getControlValue('ActionId')}]
            };
            this.queryExecutor.getValues(GetActionNameById).subscribe(data => {
                this.form.setControlValue('Action', { key: data.rows[0].values[0], value: data.rows[0].values[1] })
            });

            var css = `.menu-item {
                border: 2px solid #ff6e40;
                background: #ff6e40;
                color: white;
                display: inline-block;
                text-align: center;
                position: relative;
                cursor: pointer;
                border-radius: 5px;
            }
            .submenu {
                width: 210px;
                background: #efefef;
                right: -4px;
                padding: 5px;
                display: none;
                position: absolute;
                cursor: pointer;
                z-index: 999;
            }
            .submenu-btn-disable {
                background: #cacaca;
                border: 2px solid #bdbdbd;
            }
            .submenu-btn {
                width: 100%;
                margin-top: 5px;
                border: 1px solid #ff6e40;
                border-radius: 5px;
                background: #ff6e40;
                color: white;
                cursor: pointer;
                display: table;
            }`;

            var htmlDiv = document.createElement('div');
            htmlDiv.innerHTML = '<p></p><style>' + css + '</style>';
            document.getElementsByTagName('head')[0].appendChild(htmlDiv.childNodes[1]);

            

            const objLabels = {
                queryCode: 'ServiceTypesTexts_Labels',
                parameterValues: []
            };
            this.queryExecutor.getValue(objLabels).subscribe(data => {
                let dataLabel = JSON.parse(data);

                for (let j = 0; j < dataLabel.length; j++) {
                    if (dataLabel[j].Code === 'Title') {
                        this.Labels.Title = JSON.parse(dataLabel[j].Values)
                        this.addStyle('Title', this.Labels.Title)
                    };
                    if (dataLabel[j].Code === 'Description') {
                        this.Labels.Description = JSON.parse(dataLabel[j].Values)
                        this.addStyle('Description', this.Labels.Description)
                    };
                    if (dataLabel[j].Code === 'DescriptionWithoutExecutor') {
                        this.Labels.DescriptionWithoutExecutor = JSON.parse(dataLabel[j].Values)
                        this.addStyle('Description_without_Executor', this.Labels.DescriptionWithoutExecutor)
                    };
                    if (dataLabel[j].Code === 'Text') {
                        this.Labels.Text = JSON.parse(dataLabel[j].Values)
                        this.addStyle('Text', this.Labels.Text)
                    };
                    if (dataLabel[j].Code === 'TextWithoutExecutor') {
                        this.Labels.TextWithoutExecutor = JSON.parse(dataLabel[j].Values)
                        this.addStyle('Text_without_Executor', this.Labels.TextWithoutExecutor)
                    };
                    if (dataLabel[j].Code === 'TextWithoutPlanDate') {
                        this.Labels.TextWithoutPlanDate = JSON.parse(dataLabel[j].Values)
                        this.addStyle('Text_without_PlanDate', this.Labels.TextWithoutPlanDate)
                    };
                    if (dataLabel[j].Code === 'TextWithoutExecutor_PlanDate') {
                        this.Labels.TextWithoutExecutor_PlanDate = JSON.parse(dataLabel[j].Values)
                        this.addStyle('Text_without_Executor_PlanDate', this.Labels.TextWithoutExecutor_PlanDate)
                    };
                };
            });

            document.onmousemove=function(event) {
                var target = event.target; // где был клик?
                // console.log(event.target);
                if (target.className!='menu-item material-icons' && target.className!='submenu' && target.className!='submenu-btn') {
                    closeMenu();
                }
            }
            function closeMenu(){
                var subm=document.getElementsByClassName('submenu');
                for (var i=0; i<subm.length; i++) {
                    subm[i].style.display="none";
                }
            }
        },
        addStyle: function (InputCode, LabelData) {
            var t  = document.getElementById(InputCode);
                var menu = document.createElement("span");
                menu.style.float = 'right';
                menu.style.width = '60px';
                menu.className = 'menu-item material-icons';
                menu.id = 'menuItem_'+InputCode;
                menu.innerText = 'code';
                t.parentElement.insertBefore(menu, t);                 

                var submenu = document.createElement("div");
                submenu.className = 'submenu';
                menu.appendChild(submenu);
            
                //ADD BUTTONS
                for (let i = 0; i < LabelData.length; i++) {
                    var btn = document.createElement("button");
                    btn.className = 'submenu-btn';
                    btn.innerText = LabelData[i].Name;
                    btn.id = 'AddTag'+InputCode+LabelData[i].Id;
                    submenu.appendChild(btn);
                    document.getElementById(btn.id).addEventListener('click', function() {
                        this.insertText(InputCode, LabelData[i].Code);
                        this.recalc_content(InputCode);
                    }.bind(this));
                }
                ///////////////////


                document.getElementById('menuItem_'+InputCode).onmouseover= function(event) {
                    var target = event.target; // где был клик?
                    if (target.className == 'menu-item material-icons') {
                        var s=target.getElementsByClassName('submenu');
                        closeMenu();
                        s[0].style.display='block';                        
                    }
                }.bind(this);
                

                function closeMenu(){
                    var subm=document.getElementsByClassName('submenu');
                    for (var i=0; i<subm.length; i++) {
                        subm[i].style.display="none";
                    }
                }
        },
        recalc_content: function (InputCode) {
            this.form.setControlValue(InputCode, document.getElementById(InputCode).value);
        },
        insertText: function ( id, text ) {
            //ищем элемент по id
              var txtarea = document.getElementById(id);
              //ищем первое положение выделенного символа
              var start = txtarea.selectionStart;
              //ищем последнее положение выделенного символа
              var end = txtarea.selectionEnd;
              // текст до + вставка + текст после (если этот код не работает, значит у вас несколько id)
              var finText = txtarea.value.substring(0, start) + text + txtarea.value.substring(end);
              // подмена значения
              txtarea.value = finText;
              // возвращаем фокус на элемент
              txtarea.focus();
              // возвращаем курсор на место - учитываем выделили ли текст или просто курсор поставили
              txtarea.selectionEnd = ( start == end )? (end + text.length) : end ;
        }
    };
}());
