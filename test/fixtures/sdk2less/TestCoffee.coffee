Ext.define 'CoffeeCard',
    extend: 'Rally.ui.cardboard.Card'
    alias: 'widget.customcard'
    config:
      showHeaderMenu: true,
      editable: true,
      fields: ['Name', 'Parent', 'Tasks', 'State','PlanEstimate']
    foo:()->