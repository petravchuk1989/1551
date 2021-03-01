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
            
            this.FormCheck();
            this.form.onControlValueChanged('ServiceTypeId', this.Changed_ServiceTypeId);
            this.form.onControlValueChanged('Action', this.Changed_Action);
            this.form.onControlValueChanged('UseClaimTypeTitle', this.Changed_UseClaimTypeTitle);
            this.form.onControlValueChanged('UseClaimTypeDescription', this.Changed_UseClaimTypeDescription);
            this.form.onControlValueChanged('UseClaimTypeText', this.Changed_UseClaimTypeText);
            
            // this.addStyle();

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
        FormCheck: function() {
            if (this.form.getControlValue('UseClaimTypeTitle')) {
                this.details.setVisibility('SN_Det1', true);
                this.form.disableControl('Title');
                if (document.getElementById('menuItem_Title')) {
                    document.getElementById('menuItem_Title').classList.add('submenu-btn-disable');
                };
            } else {
                this.details.setVisibility('SN_Det1', false);
                this.form.enableControl('Title');
                if (document.getElementById('menuItem_Title')) {
                    document.getElementById('menuItem_Title').classList.remove('submenu-btn-disable');
                };
            };

            if (this.form.getControlValue('UseClaimTypeDescription')) {
                this.details.setVisibility('SN_Det2', true);
                this.form.disableControl('Description');
                this.form.disableControl('Description_without_Executor');
                if (document.getElementById('menuItem_Description')) {
                    document.getElementById('menuItem_Description').classList.add('submenu-btn-disable');
                };
                if (document.getElementById('menuItem_Description_without_Executor')) {
                    document.getElementById('menuItem_Description_without_Executor').classList.add('submenu-btn-disable');
                };
            } else {
                this.details.setVisibility('SN_Det2', false);
                this.form.enableControl('Description');
                this.form.enableControl('Description_without_Executor');
                if (document.getElementById('menuItem_Description')) {
                    document.getElementById('menuItem_Description').classList.remove('submenu-btn-disable');
                };
                if (document.getElementById('menuItem_Description_without_Executor')) {
                    document.getElementById('menuItem_Description_without_Executor').classList.remove('submenu-btn-disable');
                };                
            };

            if (this.form.getControlValue('UseClaimTypeText')) {
                this.details.setVisibility('SN_Det3', true);
                this.form.disableControl('Text');
                this.form.disableControl('Text_without_Executor');
                this.form.disableControl('Text_without_PlanDate');
                this.form.disableControl('Text_without_Executor_PlanDate');
                if (document.getElementById('menuItem_Text')) {
                    document.getElementById('menuItem_Text').classList.add('submenu-btn-disable');
                };
                if (document.getElementById('menuItem_Text_without_Executor')) {
                    document.getElementById('menuItem_Text_without_Executor').classList.add('submenu-btn-disable');
                };   
                if (document.getElementById('menuItem_Text_without_PlanDate')) {
                    document.getElementById('menuItem_Text_without_PlanDate').classList.add('submenu-btn-disable');
                };
                if (document.getElementById('menuItem_Text_without_Executor_PlanDate')) {
                    document.getElementById('menuItem_Text_without_Executor_PlanDate').classList.add('submenu-btn-disable');
                };   
            } else {
                this.details.setVisibility('SN_Det3', false);
                this.form.enableControl('Text');
                this.form.enableControl('Text_without_Executor');
                this.form.enableControl('Text_without_PlanDate');
                this.form.enableControl('Text_without_Executor_PlanDate');
                if (document.getElementById('menuItem_Text')) {
                    document.getElementById('menuItem_Text').classList.remove('submenu-btn-disable');
                };
                if (document.getElementById('menuItem_Text_without_Executor')) {
                    document.getElementById('menuItem_Text_without_Executor').classList.remove('submenu-btn-disable');
                };   
                if (document.getElementById('menuItem_Text_without_PlanDate')) {
                    document.getElementById('menuItem_Text_without_PlanDate').classList.remove('submenu-btn-disable');
                };
                if (document.getElementById('menuItem_Text_without_Executor_PlanDate')) {
                    document.getElementById('menuItem_Text_without_Executor_PlanDate').classList.remove('submenu-btn-disable');
                };   
            };

            this.form.markAsSaved();
        },
        RefreshDetails: function() {
            const parameters_01 = [
                { key: '@ServiceTypeId', value: this.form.getControlValue('ServiceTypeId') },
                { key: '@ActionId', value: this.form.getControlValue('Action') }
            ];
            this.details.loadData('SN_Det1', parameters_01);

            const parameters_02 = [
                { key: '@ServiceTypeId', value: this.form.getControlValue('ServiceTypeId') },
                { key: '@ActionId', value: this.form.getControlValue('Action') }
            ];
            this.details.loadData('SN_Det2', parameters_02);

            const parameters_03 = [
                { key: '@ServiceTypeId', value: this.form.getControlValue('ServiceTypeId') },
                { key: '@ActionId', value: this.form.getControlValue('Action') }
            ];
            this.details.loadData('SN_Det3', parameters_03);

            this.form.markAsSaved();
        },
        Changed_Action: function(value) {
            this.RefreshDetails();            
        },
        Changed_ServiceTypeId: function(value) {
            this.RefreshDetails();            
        },
        Changed_UseClaimTypeTitle: function(value) {
            this.FormCheck();            
        },
        Changed_UseClaimTypeDescription: function(value) {
            this.FormCheck();            
        },
        Changed_UseClaimTypeText: function(value) {
            this.FormCheck();            
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
                        if (InputCode === 'Title' && !this.form.getControlValue('UseClaimTypeTitle')) {
                            s[0].style.display='block';
                        }
                        if (InputCode === 'Description' && !this.form.getControlValue('UseClaimTypeDescription')) {
                            s[0].style.display='block';
                        }   
                        if (InputCode === 'Description_without_Executor' && !this.form.getControlValue('UseClaimTypeDescription')) {
                            s[0].style.display='block';
                        }   
                        if (InputCode === 'Text' && !this.form.getControlValue('UseClaimTypeText')) {
                            s[0].style.display='block';
                        }   
                        if (InputCode === 'Text_without_Executor' && !this.form.getControlValue('UseClaimTypeText')) {
                            s[0].style.display='block';
                        }   
                        if (InputCode === 'Text_without_PlanDate' && !this.form.getControlValue('UseClaimTypeText')) {
                            s[0].style.display='block';
                        }  
                        if (InputCode === 'Text_without_Executor_PlanDate' && !this.form.getControlValue('UseClaimTypeText')) {
                            s[0].style.display='block';
                        }                             
                    }
                }.bind(this);
                

                function closeMenu(){
                    var subm=document.getElementsByClassName('submenu');
                    for (var i=0; i<subm.length; i++) {
                        subm[i].style.display="none";
                    }
                }

                this.FormCheck();
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
