/**
 * A special cardboard card for use by the PortfolioKanbanApp
 */
Ext.define('Rally.app.portfolioitem.PortfolioKanbanCard', {
    extend:'Rally.ui.cardboard.ArtifactCard',
    alias:'widget.rallyportfolioestimationcard',

    inheritableStatics:{

        getAdditionalFetchFields:function () {
            return ['Owner', 'FormattedID', 'PercentDoneByStoryCount', 'StateChangedDate','State',"Parent"];
        }

    },

    _hasReadyField:function () {
        return false;
    },

    _hasBlockedField:function () {
        return false;
    },

    buildContent:function () {
        var cardBody = Ext.widget('container', {
            cls:'cardContent'
        });

        cardBody.add({
            xtype:'rallyfieldrenderer',
            field:this.getRecord().getField('_refObjectName'),
            record:this.getRecord()
        });

        var percentDoneByStoryCount = this.getRecord().get('PercentDoneByStoryCount');

        if (percentDoneByStoryCount > 0) {
            var percentDoneField = Ext.widget('rallyfieldrenderer', {
                field:this.getRecord().getField('PercentDoneByStoryCount'),
                record:this.getRecord()
            });

            cardBody.add(percentDoneField);
        }

        var stateChangedDate = this.getRecord().get('StateChangedDate');
        var timeInState = Math.floor((((new Date().getTime()) - stateChangedDate.getTime()) / (1000 * 60 * 60 * 24)));
        var timeInStateStr;
        if (timeInState === 1) {
            timeInStateStr = timeInState + ' day';
        } else if (timeInState < 21) {
            timeInStateStr = timeInState + ' days';
        } else {
            timeInStateStr = Math.floor(timeInState / 7) + " weeks";
        }

        var record = this.getRecord();
        var state = record.get('State');
        var columnName = state ? state._refObjectName : "No Entry";
        if (timeInState > 0) {
            cardBody.add({
                xtype:'component',
                cls:'timeInState',
                renderTpl:'{timeInState} in {columnName} column',
                renderData:{
                    timeInState:timeInStateStr,
                    columnName: columnName
                }
            });
        }

        if(record.get('Parent')){

            cardBody.add({
                xtype:'component',
                cls:'timeInState',
                renderTpl:'Parent : {parent}',
                renderData:{
                    parent:record.get('Parent')._refObjectName
                }
            });
        }

        return cardBody;
    }

});


