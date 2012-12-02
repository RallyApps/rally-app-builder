Ext.onReady(function() {
    var old = Rally.util.Navigation.createRallyDetailUrl;
    Rally.util.Navigation.createRallyDetailUrl = function(input, relative) {
        var ref = Rally.util.Ref.getRefUri(input);
        if (ref) {
            var type = "portfolioitem";
            //construct the url the "old" way
            var refUrl = this._getContextPath() + "/detail/" + type +
                "/" + Rally.util.Ref.getTypeFromRef(ref) + "/" + Rally.util.Ref.getOidFromRef(ref);
            if (relative) {
                return refUrl;
            } else {

                var oldDetail =  ref.replace(this.getWebServicePrefixRegex(), refUrl);
                return oldDetail.replace('slm','#');
            }
        }
    }
});