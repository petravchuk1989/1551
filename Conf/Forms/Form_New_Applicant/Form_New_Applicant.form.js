(function() {
    return {
        init: function() {
            this.form.disableControl('phone_number');
        },
        afterSave: function() {
            const appeal_id = this.form.getControlValue('appeals');
            this.navigateTo('/sections/Appeals/edit/' + appeal_id);
        }
    };
}());
