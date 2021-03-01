(function() {
    return {
        placeholder: '',
        type: 'DateTime',
        stepMinute: 1,
        timeOnly: false,
        onItemSelect: function(date) {
            this.yourFunctionName(date);
        },
        initValue: function() {
            let currentDate = new Date();
            let year = currentDate.getFullYear();
            let monthFrom = currentDate.getMonth();
            let dayTo = currentDate.getDate();
            let hh = currentDate.getHours();
            let mm = currentDate.getMinutes();
            let defaultValue = {
                dateFrom: this.toUTC(new Date(year, monthFrom , '01', '00', '00')),
                dateTo: this.toUTC(new Date(year, monthFrom , dayTo, hh, mm))
            }
            this.setDefaultValue(defaultValue);
        },
        toUTC(val) {
            let date = new Date(val);
            let year = date.getFullYear();
            let monthFrom = date.getMonth();
            let dayTo = date.getDate();
            let hh = date.getHours();
            let mm = date.getMinutes();
            let dateTo = new Date(year, monthFrom , dayTo, hh + 3, mm)
            return dateTo
        },
        yourFunctionName: function(date) {
            let message = {
                name: '',
                package: {
                    dateFrom: date.dateFrom,
                    dateTo: date.dateTo
                }
            }
            this.messageService.publish(message);
        }
    };
}());
