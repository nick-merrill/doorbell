Router.configure {
  layoutTemplate: 'layout'
  notFoundTemplate: 'notFound'
  loadingTemplate: 'loading'
}

Router.onBeforeAction('loading')

Router.map ->
  this.route 'ring', {
    path: '/ring/:id'
    template: 'bell'
    waitOn: ->
      Meteor.subscribe('bells')
    data: -> {
        name: 'ring'
        bell: Bells.findOne({id: parseInt(@params.id)})
      }
  }

  this.route 'receive', {
    path: '/receive/:id'
    template: 'receiver'
    waitOn: ->
      Meteor.subscribe('bells')
    data: -> {
        name: 'receive'
        bell: Bells.findOne({id: parseInt(@params.id)})
      }
  }

  this.route 'notFound', {
    path: '*'
  }

