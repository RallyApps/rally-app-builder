Ext.define('CustomApp', {
    extend: 'Rally.app.App',
    componentCls: 'app',
    items:{ html:'<a href="https://help.rallydev.com/apps/{{sdk_version}}/doc/">App SDK {{sdk_version}} Docs</a>'},
    launch: function() {
        //Write app code here
    }
});
