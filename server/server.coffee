Meteor.startup ->
  # Remove all bells and insert default bell
  Bells.upsert({id: 1}, {$set: {
    id: 1
    name: "Nick's Room"
    response: ""
  }})

Meteor.publish 'bells', ->
  return Bells.find({})
