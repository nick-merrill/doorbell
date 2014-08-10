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
  big = false
  if shouldBeActive && !titleAnimationInterval?
    (new PNotify {
      title: "Doorbell"
      text: "Click to invite in"
      hide: false
      desktop: {
        desktop: true
      }
    }).get().click ->
      $('.action#come-in').click()
    titleAnimationInterval = setInterval ->
      if big
        text = "<---*-*--->"
      else
        text = "<-->"
      document.title = text
      big = !big
    , 300
  else if !shouldBeActive && titleAnimationInterval?
    clearInterval(titleAnimationInterval)
    titleAnimationInterval = null
    document.title = 'doorbell'

Template.receiver.rendered = ->
  me = @
  me.titleUpdater = Meteor.autorun ->
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


responseTimeout = null

clearBell = (bell, shouldDeactivate) ->
  newProps = {
    response: null
    responseClass: null
    responseIconClass: null
  }
  if shouldDeactivate
    newProps.isActivated = false
  Bells.update({_id: bell._id}, {$set: newProps})
  clearTimeout(responseTimeout)
  responseTimeout = null

Template.receiver.events {
  'click .action': (event) ->
    $button = $(event.currentTarget)
    responseDuration = parseInt($button.attr('response-duration')) || 15000
    bell = @bell
    clearBell(bell)
    Bells.update({_id: bell._id}, {$set : {
      response: $button.text()
      responseClass: $button.attr('response-class')
      responseIconClass: $button.attr('response-icon-class') || null
      isActivated: false
    }})
    if responseDuration
      responseTimeout = setTimeout ->
        clearBell(bell)
      , responseDuration
  'click #clear': ->
    clearBell(@bell, true)
    PNotify.desktop.permission()
}
