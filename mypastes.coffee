Boards = new Meteor.Collection("pastes")

Meteor.methods
  ensure_exists: (username) ->
    unless Boards.findOne(username: username)
      Boards.insert(username: username, pastes: [])

if Meteor.isClient
  class Router extends Backbone.Router
    routes:
      ''         : 'homepage'
      ':username': 'pastes'
    homepage: ->
      Session.set "homepage", true
    pastes: (username) ->
      Session.set "homepage", false
      Session.set "username", username
      Meteor.call "ensure_exists", username

  router = new Router

  Template.main.homepage = -> Session.get("homepage")

  Template.mypastes.helpers
    parse: (paste) ->
      if paste.split(' ').length > 1 or /\<|\>|'|"/.test(paste)
        return paste
      if /^http/.test paste
        return new Handlebars.SafeString("<a href='#{paste}'>#{paste}</a>")
      return paste

  Template.mypastes.pastes = ->
    username = Session.get "username"
    board = Boards.findOne(username: username)
    if board?
      return board.pastes.reverse()
    else
      return []

  Template.mypastes.events
    'keydown #input': (e) ->
      # 86 is 'v'
      if (e.ctrlKey or e.metaKey) and (e.keyCode == 86)
        setTimeout (-> document.getElementById('submit').click()), 10
    'submit': ->
      paste = $("#input").val()
      return false if not paste.trim().length
      $("#input").val ''
      # upsert is not supported yet
      username = Session.get("username")
      board = Boards.findOne(username: username)
      Boards.update board._id, {$push: {pastes: paste}}
      return false

  Meteor.startup ->
    Backbone.history.start(pushState: true)
