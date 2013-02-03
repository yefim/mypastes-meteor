Pastes = new Meteor.Collection("pastes")

if Meteor.isClient
  class Router extends Backbone.Router
    routes:
      '': 'index'
      ':username': 'pastes'
    index: ->
      console.log "index"
      # render index
    pastes: (username) ->
      Session.set "username", username

  router = new Router

  Template.mypastes.pastes = ->
    username = Session.get("username")
    result = Pastes.findOne(username: username)
    result.pastes.reverse() if result?
    return result
  Template.mypastes.events
    'submit': ->
      paste = $("#input").val()
      return false if not paste.trim().length
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
