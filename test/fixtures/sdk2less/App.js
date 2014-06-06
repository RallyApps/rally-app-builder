Ext.define('CustomApp', {
    extend: 'Rally.app.App',
    componentCls: 'app',
    uselessString:"Custom App File",
    launch: function() {
        var cardBoardConfig = {
            xtype: 'rallycardboard',
            types: ['User Story'],
            attribute: "ScheduleState",
            cardConfig: {
                xtype: 'customcard'
            }
        };
        this.add(cardBoardConfig);
    }
});
//Important Comment