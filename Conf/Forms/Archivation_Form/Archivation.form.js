(function() {
    return {
        newBaseCallBack(response) {
            if(response) {
                let disk = response[0].value;
                const queryForGetValue = {
                    queryCode: 'NewFilesDatabase',
                    parameterValues: [
                        {
                            key: '@Disk',
                            value: disk
                        }
                    ]
                };
                this.queryExecutor.getValue(queryForGetValue).subscribe(data => {
                    if(data === 'OK') {
                        this.openPopUpInfoDialog('БД файлів успішно створено')
                    }
                });
            }
        },
        init: function() {
            let new_filesDB = document.getElementById('new_filesDatabase');
            new_filesDB.addEventListener('click', function() {
                const newDBConfig = {
                    title: 'Нова файлова БД',
                    acceptBtnText: 'save',
                    cancelBtnText: 'exit',
                    singleButton: false,
                    fieldGroups: [
                        {
                            code: 'disk_group',
                            name: '',
                            expand: true,
                            position: 1,
                            fields: [
                                {
                                    code: 'new_dbDisk',
                                    fullScreen: true,
                                    hidden: false,
                                    placeholder: 'Введіть диск',
                                    position: 1,
                                    required: true,
                                    type: 'text'
                                }
                            ]
                        }
                    ]
                }
                this.openModalForm(newDBConfig, this.newBaseCallBack.bind(this));
            }.bind(this));
            const queryForGetValues = {
                queryCode: 'List_Disk',
                parameterValues: [],
                limit: -1
            };
            this.queryExecutor.getValues(queryForGetValues).subscribe(data => {
                for (let i = 0; i < data.rows.length; i++) {
                    let diskControl = {
                        code: 'disk_' + i,
                        type: 'text',
                        fullScreen: false,
                        position: i,
                        width: '50%',
                        value: data.rows[i].values[0]
                    }
                    let spaceControl = {
                        code: 'space_' + i,
                        type: 'text',
                        fullScreen: true,
                        position: i + 1,
                        width: '30%',
                        value: data.rows[i].values[1] + ' Мб. вільно'
                    }
                    this.form.addControl('Disk', diskControl);
                    this.form.addControl('Disk', spaceControl);
                    this.form.disableControl('disk_' + i, true);
                    this.form.disableControl('space_' + i, true);
                }
            });
            this.form.disableControl('current_db', true);
            this.form.disableControl('last_loadDate', true);
            this.form.disableControl('last_loadResult', true);
        }
    };
}());
