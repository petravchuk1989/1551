(function () {
    return {
       
        init: function() {
            document.getElementsByClassName('float_r')[0].children[1].style.display = 'none';

            this.form.disableControl('ReceiptSources');
            this.form.disableControl('Phone');
            this.form.disableControl('DateStart');
            this.form.disableControl('AppealNumber');
            this.form.disableControl('Appeal_enter_number');
        //    this.form.disableControl('Applicant_PIB');

            this.form.setControlValue('ReceiptSources', { key: 3, value: 'УГЛ' });
            this.form.setControlValue('AppealId', this.id);
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
                  this.form.setControlValue('Applicant_Sex', data.rows[0].values[13])
                  this.form.setControlValue('Applicant_BirthDate', data.rows[0].values[14])
                  this.form.setControlValue('Applicant_Email', data.rows[0].values[15])
                  this.form.setControlValue('Applicant_Comment', data.rows[0].values[16])
                  this.form.setControlValue('Applicant_PIB', data.rows[0].values[0])
            });
    }

};
}());
