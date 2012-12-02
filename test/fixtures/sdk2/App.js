Ext.define('PortfolioEstimationBoard', {
    extend:'Rally.app.App',
    layout:'auto',
    appName:'Portfolio Estimation Board',

    hidden:true,

    /**
     * The combo that controls the type
     */
    typeCombo:undefined,


    /**
     * The currently selected type
     */
    currentType:undefined,

    /**
     * An object that contains the parents for each type with the types key being the ref
     */
    typeParents:undefined,

    /**
     * The record that is the current parent, the cardboard will be filtered by it
     */
    currentParent:undefined,


    items:[
        {
            xtype:'container',
            itemId:'header',
            cls:'header'
        },
        {
            xtype:'container',
            itemId:'bodyContainer',
            width:'100%'
        }
    ],

    /**
     * @override
     */
    launch:function () {
        this.typeCombo = Ext.widget('rallycombobox', {
            fieldLabel:'Type',
            labelWidth:30,
            cls:'type-combo',
            labelClsExtra:'rui-label',
            stateful:false,
            storeConfig:{
                autoLoad:true,
                remoteFilter:false,
                filters:[
                    Ext.create('Rally.data.QueryFilter', {
                        property: 'TypePath',
                        operator: 'Contains',
                        value: 'PortfolioItem/'
                    })
                ],
                model:'TypeDefinition',
                sorters:{
                    property:'ordinalValue',
                    direction:'Desc'
                },
                cls:'typeCombo',
                defaultSelectionToFirst:false,
                context:this.getContext().getDataContext()
            }
        });

        this.typeCombo.on('select', this._loadCardboard, this);
        this.typeCombo.store.on('load', this._loadTypes, this);

        this.down('#header').add(
            [
                this.typeCombo,
                {
                    xtype: 'rallybutton',
                    itemId:'parentButton',
                    cls:'button',
                    text: 'Parent Filter Disabled',
                    handler: this._openChooserForFilter,
                    disabled:true,
                    scope:this
                },

                {
                    itemId:'clearButton',
                    xtype: 'rallybutton',
                    cls:'button',
                    hidden:true,
                    text: 'Clear Filter',
                    handler: this._clearFilter,
                    scope:this
                },
                {
                    xtype: 'addnew',
                    recordTypes: ['PortfolioItem'],
                    cls:'add-new',
                    ignoredRequiredFields: ['Name'],
                    listeners: {
                        beforerecordadd:function(addNew, options) {
                            var record = options.record;
                            record.set('PortfolioItemType', this.currentType);
                            record.set('Project', this.getContext().getProject()._ref);

                            if (this.currentParent) {
                                record.set('Parent', this.currentParent.get('_ref'));
                            }
                        },
                        recordadd: function(addNew, result) {
                            this.down('#cardboard').addCard(result.record);
                        },
                        scope:this
                    }
                }
            ]);
    },

    _showClearButton :function(currentParent) {
        this.currentParent = currentParent;
        var button = this.down('#clearButton');
        button.setVisible(true);
        button.setText(currentParent.get('Name'));

    },
    _clearFilter:function(button) {
        button.setVisible(false);
        this.currentParent = null;
        this._loadCardboard();
    },

    _manageParentChooserButton:function() {
        var button = this.down(".rallybutton");
        if (this.typeParents[this.currentType]) {
            button.setText('Filter By ' + this.typeParents[this.currentType].get('_refObjectName'));
            button.setDisabled(false);
        }
        else {
            button.setText('Parent Filter Disabled');
            button.setDisabled(true);
        }

    },

    _openChooserForFilter:function() {
        var filters = [];
        var parent = this.typeParents[this.currentType];
        if (parent) {
            filters.push({
                property: 'PortfolioItemType',
                value: parent.get('_ref')
            });
        }

        Ext.create('Rally.ui.dialog.ChooserDialog', {
            artifactTypes: ['portfolioitem'],
            autoShow: true,
            title: 'Choose ' + parent.get('_refObjectName'),
            storeConfig : {
                filters: filters
            },
            listeners: {
                artifactChosen: function(selectedRecord) {
                    this._showClearButton(selectedRecord);
                    this._loadCardboard();
                },
                scope: this
            }
        });
    },

    _loadTypes:function(store, records) {
        this.typeParents = {};
        var previousType;
        Ext.each(records, function(type) {
            var ref = type.get('_ref');
            this.typeParents[ref] = previousType;
            previousType = type;
        }, this);

        this.types = records;
        this._loadCardboard();
    },

    _loadCardboard:function () {
        this.currentType = this.typeCombo.getValue();
        this.down('.addnew').updateTypeText(this.typeCombo.getRawValue());
        this._manageParentChooserButton();
        this._loadStates({
            success:function (states) {
                var columns = this._createColumns(states);
                this.setVisible(true);
                this._drawCardboard(columns);
            },
            scope:this
        });
    } ,

    /**
     * @private
     * We need the States of the selected Portfolio Item Type to know what columns to show.
     * Whenever the type changes, reload the states to redraw the cardboard.
     * @param options
     * @param options.success called when states are loaded
     * @param options.scope the scope to call success with
     */
    _loadStates:function (options) {
        Ext.create('Rally.data.WsapiDataStore', {
            model:'PreliminaryEstimate',
            context:this.getContext().getDataContext(),
            autoLoad:true,
            fetch : true,
            sorters:[
                {
                    property:'Value',
                    direction:'ASC'
                }
            ],
            listeners:{
                load:function (store, records) {
                    if (options.success) {
                        options.success.call(options.scope || this, records);
                    }
                }
            }
        });

    },

    /**
     * Given a set of columns, build a cardboard component. Otherwise show an empty message.
     * @param columns
     */
    _drawCardboard:function (columns) {
        if (columns) {
            var cardboard = this.down('#cardboard');
            if (cardboard) {
                cardboard.destroy();
            }
            var filters = [
                {
                    property:'PortfolioItemType',
                    value:this.currentType
                }
            ];
            if (this.currentParent) {
                filters.push({
                    property:'Parent',
                    value:this.currentParent.get('_ref')
                });
            }
            cardboard = Ext.widget('rallycardboard', {
                types:['PortfolioItem'],
                itemId:'cardboard',
                attribute:'PreliminaryEstimate',
                columns:columns,
                maxColumnsPerBoard:columns.length,
                ddGroup:this.typeCombo.getValue(),
                enableRanking:this.getContext().get('workspace').WorkspaceConfiguration.DragDropRankingEnabled,
                cardConfig:{
                    xtype:'rallyportfolioestimationcard'
                },
                storeConfig:{
                    filters: filters
                },

                loadDescription:'Portfolio Estimation Board'
            });

            this.down('#bodyContainer').add(cardboard);

            this._attachPercentDoneToolTip(cardboard);

            Ext.EventManager.onWindowResize(cardboard.resizeAllColumns, cardboard);
        } else {
            this._showNoColumns();
        }

    } ,

    _showNoColumns:function () {
        this.add({
            xtype:'container',
            cls:'no-type-text',
            html:'<p>This Type has no states defined.</p>'
        });
    },

    /**
     * @private
     * @return columns for the cardboard, as a map with keys being the column name.
     */
    _createColumns:function (states) {
        var columns;

        if (states.length) {

            columns = [
                {
                    displayValue:'No Entry',
                    value:null,
                    cardLimit:50
                }
            ];

            Ext.Array.each(states, function (state) {
                columns.push({
                    value:state.get('_ref'),
                    displayValue:state.get('Name'),
                    wipLimit:state.get('WIPLimit'),
                    policies:state.get('Description')
                });
            });
        }

        return columns;
    }    ,

    _attachPercentDoneToolTip:function (cardboard) {
        Ext.create('Rally.ui.tooltip.PercentDoneToolTip', {
            target:cardboard.getEl(),
            delegate:'.percentDoneContainer',
            listeners:{
                beforeshow:function (tip) {

                    var cardElement = Ext.get(tip.triggerElement).up('.cardContainer');
                    var card = Ext.getCmp(cardElement.id);

                    tip.updateContent(card.getRecord().data);
                },
                scope:this
            }
        });
    }


})
    ;

