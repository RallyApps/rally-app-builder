describe('CustomApp', function() {

    it('should render the app', function() {
        var app = Rally.test.Harness.launchApp('CustomApp');
        expect(app.getEl()).toBeDefined();
    });
    
});
