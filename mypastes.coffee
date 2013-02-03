Pastes = new Meteor.Collection("pastes")

if Meteor.isClient
  class Router extends Backbone.Router
    routes:
      '': 'index'
      ':username': 'get_pastes'
    index: ->
      console.log "index"
      # render index
    get_pastes: (username) ->
      Session.set "username", username

  router = new Router

  Template.mypastes.pastes = ->
    username = Session.get("username")
    Pastes.findOne(username: username)
  Template.mypastes.events
    'click #submit': ->
      paste = $("#input").val()
      # need to implement my own upsert
      username = Session.get("username")
      pastes = Pastes.findOne(username: username)
      if pastes
        Pastes.update username: username,
                      $push: {pastes: paste}
      else
        Pastes.insert
          username: username
          pastes: [paste]

  Meteor.startup ->
    Backbone.history.start(pushState: true)

if Meteor.isServer
  Meteor.startup ->
