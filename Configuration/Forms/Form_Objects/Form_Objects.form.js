(function () {
  return {
    init:function(){
        this.form.disableControl('full_name');
        this.form.disableControl('district_id');
        // this.form.disableControl('is_active');
        
        
        
        let type = this.form.getControlValue('obj_type_id');
        console.log(type);
        if(type != null){
            let type = this.form.getControlDisplayValue('obj_type_id');
            let bul = this.form.getControlDisplayValue('builbing_id');
            let name = this.form.getControlValue('object_name');
        
            if (name === null){
                this.form.setControlValue('full_name', type + ' : ' + bul);
            }else{
             this.form.setControlValue('full_name', type + ' : ' + bul +' ('+ name + ')');
            }
        };
        
        
        this.form.onControlValueChanged('object_name', this.fullName);
        
    },
    
    fullName:function(name){
        let type = this.form.getControlDisplayValue('obj_type_id');
        let bul = this.form.getControlDisplayValue('builbing_id');
        
         this.form.setControlValue('full_name', type + ' : ' + bul +' ('+ name + ')');
        
    }
};
}());
