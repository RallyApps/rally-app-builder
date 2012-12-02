Ext.define('Rally.app.AddNew', {
    extend:'Rally.ui.AddNew',
    alias:'widget.addnew',
    updateTypeText:function(type) {
        var newContainer = this.down('#new');
        this.newButtonText = "+ Add New " + type;
        this.fieldLabel = "New "+type;
        this.setFieldLabel(this.fieldLabel);
        newContainer.setText(this.newButtonText);
    }
});