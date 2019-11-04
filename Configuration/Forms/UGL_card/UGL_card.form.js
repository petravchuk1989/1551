(function () {
    return {
       
        init: function() {
            document.getElementsByClassName('float_r')[0].children[1].style.display = 'none';

            this.form.disableControl('ReceiptSources');
            this.form.disableControl('Phone');
            this.form.disableControl('DateStart');
            this.form.disableControl('AppealNumber');
            this.form.disableControl('Appeal_enter_number');
            this.form.disableControl('Applicant_District');
            this.form.disableControl('Applicant_Age');
            this.form.disableControl('ExecutorInRoleForObject');
        //  this.form.disableControl('Applicant_PIB');

            this.form.setControlValue('ReceiptSources', { key: 3, value: 'УГЛ' });
            this.form.setControlValue('AppealId', this.id);
        // Если Applicant_Id в форме не задан то создавать Questions еще рано (заявителя нету)
            if(this.form.getControlValue('Applicant_Id') == null) {
                document.getElementById('Question_Aplicant_Btn_Add').disabled = true;
                     };

            this.form.onControlValueChanged('Applicant_Id', this.checkApplicantHere);
            this.form.setGroupVisibility('UGL_Group_CreateQuestion', false);

            if(this.form.getControlValue('Applicant_PIB') == null ||
               this.form.getControlValue('Applicant_Building') == null)
            { document.getElementById('Applicant_Btn_Add').disabled = true; };

            this.form.onControlValueChanged('Applicant_PIB', this.checkApplicantSaveAvailable);
            this.form.onControlValueChanged('Applicant_Building', this.checkApplicantSaveAvailable);
        // Заполнение полей "Загальна інформація" исходя из AppealId          
            const AppealUGL = {
                queryCode: 'AppealUGL_Info',
                parameterValues: [
                    {
                        key: '@Id',
                        value: this.form.getControlValue('AppealId')
                    }
                ]
            };
            
            this.queryExecutor.getValues(AppealUGL).subscribe(data => {
                 this.form.setControlValue('Appeal_enter_number', data.rows[0].values[0]); 
                 this.form.setControlValue('Phone', data.rows[0].values[1])
                 this.form.setControlValue('CardPhone', data.rows[0].values[3])
                 this.form.setControlValue('DateStart', data.rows[0].values[2])
                 this.form.setControlValue('Applicant_Phone_Hide', data.rows[0].values[3])
                 this.form.setControlValue('Applicant_PIB', data.rows[0].values[4])
                 this.form.setControlValue('Question_Content', data.rows[0].values[5])
                 this.form.setControlValue('ApplicantUGL', data.rows[0].values[6])
        // Загрузка заявителей по телефону в деталь
                 const parameters = [
                    { key: '@applicant_phone', value: this.form.getControlValue('CardPhone') }
                ];
                    this.details.loadData('Detail_UGL_Aplicant', parameters);
            });
        // Получение данных выбранного из детали заявителя по телефону             
                 this.details.onCellClick('Detail_UGL_Aplicant', this.getApplicantInfo.bind(this)); 
                 
                 //Кнопка "Очистити" в группе "Заявник"
                 document.getElementById('Applicant_Btn_Clear').addEventListener("click", function(event) {
                  
                    this.form.setControlValue('Applicant_Id', null);
                    this.form.setControlValue('Applicant_PIB', null);
                    this.form.setControlValue('Applicant_District', null);
                    this.form.setControlValue('Applicant_Building', {});
                    this.form.setControlValue('Applicant_HouseBlock', null);
                    this.form.setControlValue('Applicant_Entrance', null);
                    this.form.setControlValue('Applicant_Flat', null);
                    this.form.setControlValue('Applicant_Privilege', {});
                    this.form.setControlValue('Applicant_SocialStates', {});
                    this.form.setControlValue('Applicant_CategoryType', {});
                    this.form.setControlValue('Applicant_Type', {});
                    this.form.setControlValue('Applicant_Sex',  null);
                    this.form.setControlValue('Applicant_BirthDate',null);
                    this.form.setControlValue('Applicant_Age', null);
                    this.form.setControlValue('Applicant_Email', null);
                    this.form.setControlValue('Applicant_Comment', null);
                    this.form.setControlValue('Applicant_Phone_Hide', null);
               //     this.form.setControlValue('CardPhone', null);                    
                    this.form.setControlValue('CardPhone', this.form.getControlValue('Phone'));
                
                }.bind(this)); 
                // Отработка кнопки "Додати питання"
                document.getElementById('Question_Aplicant_Btn_Add').addEventListener("click", function(event) {
                    this.form.setGroupVisibility('UGL_Group_CreateQuestion', true);
                    this.form.setGroupExpanding('UGL_Group_Aplicant', false);
                }.bind(this));
         }, 
         // END INIT
         checkApplicantHere: function() {   
                if (this.form.getControlValue('Applicant_Id') != null) {
                    document.getElementById('Question_Aplicant_Btn_Add').disabled = false;
                }
                else {  
                    document.getElementById('Question_Aplicant_Btn_Add').disabled = true;
            };
        },

        checkApplicantSaveAvailable: function() {
            if(this.form.getControlValue('Applicant_PIB') == null ||
               this.form.getControlValue('Applicant_Building') == null)
            { 
                document.getElementById('Applicant_Btn_Add').disabled = true;
                    }
            else {
                document.getElementById('Applicant_Btn_Add').disabled = false;
            };
        },

         getApplicantInfo: function(column, row, value, event, indexOfColumnId) {
            let applicantId = row.values[4];
            console.log(applicantId);

            const Applicant = {
                queryCode: 'Applicant_Info',
                parameterValues: [
                    {
                        key: '@applicantId',
                        value: applicantId
                    }
                ] 
            }
    // Наполнение полей заявителя данными выбраного с детали
            this.queryExecutor.getValues(Applicant).subscribe(data => { 
            
            let BirthDate = null;
            if(data.rows[0].values[14] == null) {
                BirthDate = null;
            } else {
                BirthDate = new Date(data.rows[0].values[14]);
            };

            let sex = null;
            if(data.rows[0].values[13] == null) {
                sex = null;
            } else {
                sex = (data.rows[0].values[13]).toString();
            };

                  console.log(data);
                  this.form.setControlValue('Applicant_Building', 
                  { key: data.rows[0].values[1], value: data.rows[0].values[2] }); 
                  this.form.setControlValue('Applicant_Entrance', data.rows[0].values[4])
                  this.form.setControlValue('Applicant_Flat', data.rows[0].values[5])
                  this.form.setControlValue('Applicant_District', data.rows[0].values[6])
                  this.form.setControlValue('Applicant_Privilege',
                  { key: data.rows[0].values[7], value: data.rows[0].values[8] });
                  this.form.setControlValue('Applicant_SocialStates', 
                  { key: data.rows[0].values[9], value: data.rows[0].values[10] });
                  this.form.setControlValue('Applicant_Type', 
                  { key: data.rows[0].values[11], value: data.rows[0].values[12] });
                  this.form.setControlValue('Applicant_Sex', sex);
                  this.form.setControlValue('Applicant_BirthDate', BirthDate);
                  this.form.setControlValue('Applicant_Email', data.rows[0].values[15]);
                  this.form.setControlValue('Applicant_Comment', data.rows[0].values[16]);
                  this.form.setControlValue('Applicant_PIB', data.rows[0].values[0]);
                  this.form.setControlValue('Applicant_Id', data.rows[0].values[17]);
                  this.form.setControlValue('Applicant_Age', data.rows[0].values[18]);
            });
    }

};
}());
