setActive = (bell, shouldBeActive) ->
  Bells.update({_id: bell._id}, {$set: {
    isActivated: shouldBeActive
  }})

Template.bell.helpers {
  bellButtonClass: ->
    bell = @bell
    if !bell?
      return
    if bell.isActivated
      'btn-danger'
    else
      'btn-primary'
}

Template.bell.events({
  'click #ring': ->
    # template data, if any, is available in 'this'
    bell = @bell
    setActive(bell, !bell.isActivated)
})

Template.switcher.events {
  'click #switch': ->
    name = Router.current().data().name
    if name == 'ring'
      Router.go('receive', {id: @bell.id})
    else
      Router.go('ring', {id: @bell.id})
}

titleAnimationInterval = null
setAnimateTitle = (shouldBeActive) ->
  low = 0
  high = 5
  titleState = low
  if shouldBeActive && !titleAnimationInterval?
    titleAnimationInterval = setInterval ->
      if titleState > high
        titleState = low
      text = ""
      for i in [0..titleState]
        text += "-"
      text += ">"
      document.title = text
      titleState++
    , 300
  else if !shouldBeActive && titleAnimationInterval?
    clearInterval(titleAnimationInterval)
    document.title = 'doorbell'

Template.receiver.rendered = ->
  me = @
  me.titleUpdater = Meteor.autorun ->
    console.log(me.data)
    bell = me.data.bell
    if bell?
      b = Bells.findOne({id: bell.id})
      if b.isActivated
        setAnimateTitle(true)
      else
        setAnimateTitle(false)

Template.receiver.destroyed = ->
  if titleAnimationInterval?
    setAnimateTitle(false)
  @titleUpdater = null
