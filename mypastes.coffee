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
    'submit': ->
      paste = $("#input").val()
      return false if not paste.length
      $("#input").val ''
      # upsert is not supported yet
      username = Session.get("username")
      pastes = Pastes.findOne(username: username)
      if pastes
        Pastes.update({username: username}, $push: {pastes: paste})
      else
        Pastes.insert
          username: username
          pastes: [paste]
      return false

  Meteor.startup ->
    Backbone.history.start(pushState: true)

if Meteor.isServer
  Meteor.startup ->
