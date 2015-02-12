Ext.define('CustomCard', {
    extend: 'Rally.ui.cardboard.Card',
    alias: 'widget.customcard',
    config: {
        showHeaderMenu: true,
        editable: true,
        fields: ['Name', 'Parent', 'Tasks', 'State','PlanEstimate']
    },
    inheritableStatics: {
        getFetchFields: function() {
            return ['Owner', 'FormattedID', 'Blocked', 'Ready', 'Name', 'PlanEstimate','Parent'];
        }
    },
    initComponent: function() {
        this.callParent(arguments);
        var priority = this.getRecord().get("Blocked").toString();
        this.addCls(priority);
    }
});