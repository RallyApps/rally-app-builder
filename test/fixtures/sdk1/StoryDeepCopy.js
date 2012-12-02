rally.StoryDeepCopy = function (rallyDataSource, config) {
    var storyBuffer = [];
    var firstStory = null;
    var finishedCallback;
    var that = this;

    function getTypeFromRef(ref) {
        if (rally.sdk.util.Ref.isRef(ref)) {
            var list = ref.split("/");
            list.pop();
            return list.pop();
        }
        else {
            throw "Function getTypeFromRef expected a Rally Reference.";
        }
    }

    //dojo.connect(obj, event, context, method, dontFix);
    this._fireEvent = function(eventName, eventArgs) {

        if (config && config.eventListeners[eventName] && dojo.isFunction(config.eventListeners[eventName])) {
            config.eventListeners[eventName](that, eventArgs);
        }
    };

    // removes private and read only fields to keep from pushing them up.
    this.filterObject = function (object) {
        delete object.Discussion;
        delete object.Rank;
        delete object.LastUpdateDate;
        delete object.Attachments;
        delete object.AcceptedDate;
        delete object.Blocker;
        delete object.Defects;
        delete object.TaskActualTotal;
        delete object.TaskEstimateTotal;
        delete object.TaskRemainingTotal;
        delete object.TaskEstimateTotal;
        delete object.RevisionHistory;
        delete object.Subscription;
        delete object.FormattedID;
        delete object.CreationDate;
        delete object.Changesets;
        delete object.ObjectID;
        for (var j in object) {
            if (j.substring(0, 1) == '_') {
                delete object[j];
            }
        }
        return object;
    };

    this._addObject = function(object, typeName, callback) {
        var item = dojo.clone(object);
        item = this.filterObject(item);
        function errorFunctionWrapper(error) {
            if (dojo.isArray(error.Errors)) {
                var errorMessage = error.Errors.pop();
                if (errorMessage.indexOf("Not authorized to create:") >= 0) {
                    errorMessage = "Unable to create an object. This can happen due to a child or task being in a project you do not have write permissions to.";
                }
                rally.sdk.ui.AppHeader.showMessage("error", errorMessage, 10000);
            }
            else if(dojo.isObject(error)&&error.message){
                rally.sdk.ui.AppHeader.showMessage("error", error.message, 10000);
                error = [error.message];
            }
            if (dojo.isFunction(config.onError)) {
                config.onError(error);
            }
        }

        rallyDataSource.create(typeName, item, callback, errorFunctionWrapper);
    };

    this._copyAllFromBuffer = function() {
        if (storyBuffer.length > 0) {
            var story = storyBuffer.pop();
            that._copyStory(story.ref, story.parent, that._copyAllFromBuffer);
        }
        else {
            if (finishedCallback) {
                finishedCallback(firstStory);
            }
        }
    };

    this._addStoriesToBuffer = function(storyArray, parentRef) {
        dojo.forEach(storyArray, function (story) {
            storyBuffer.push({
                ref: story._ref,
                parent: parentRef
            });
        });
    };

    this._copyStory = function(ref, parentRef, callback) {
        rallyDataSource.getRallyObject(ref, function (foundObject) {
            var type = getTypeFromRef(ref);
            that._fireEvent("storyPreAdd", {story:foundObject});
            if (parentRef) {
                foundObject.Parent = parentRef;
            }
            else {
                foundObject.Name = "(Copy of) " + foundObject.Name;
            }
            that._addObject(foundObject, type, function (storyRef) {
                if (!firstStory) {
                    firstStory = storyRef;
                }
                that._fireEvent("storyPostAdd", {});
                that._addStoriesToBuffer(foundObject.Children, storyRef);
                that._copyTasksToStory(foundObject.Tasks, storyRef, callback);
            }, null);
        });
    };

    this._copyTasksToStory = function(tasks, storyRef, callback) {
        //Copy the array
        var localTasks = tasks.slice(0);
        if (localTasks.length > 0) {
            var task = localTasks.pop();
            that._copyTask(task._ref, storyRef, function () {
                that._copyTasksToStory(localTasks, storyRef, callback);
            });
        }
        else {
            callback();
        }
    };

    this._copyTask = function(ref, storyRef, callback) {
        rallyDataSource.getRallyObject(ref, function (foundObject) {
            var type = getTypeFromRef(ref);
            foundObject.WorkProduct = storyRef;
            that._fireEvent("taskPreAdd", {task:foundObject});
            that._addObject(foundObject, type, function (ref, warnings) {
                if (callback) {
                    that._fireEvent("taskPostAdd", [ref]);
                    callback();
                }
            }, null);
        });
    };

    this.copyStory = function (ref, callback) {
        that._copyStory(ref, undefined, that._copyAllFromBuffer);
        finishedCallback = callback;
    };
};