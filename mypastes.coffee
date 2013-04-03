Pastes = new Meteor.Collection("pastes")

if Meteor.isServer
  Pastes.allow
    insert: (userId, doc) ->
      not Pastes.findOne {username: doc.username}

    update: (userId, docs) ->
      if docs.length != 1
        false

      doc = docs[0]

      (not doc.privateTo) or (doc.privateTo == userId)

  Meteor.publish null, ->
    Pastes.find {$or: [{privateTo: this.userId}, {privateTo: {$exists: false}}]}

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

  router = new Router

  Template.main.homepage = -> Session.get("homepage")

  Template.mypastes.visible = ->
    paste = Pastes.findOne({username: Session.get("username")})
    if (not paste)
      return true

    return ((not paste.privateTo) or (paste.privateTo == Meteor.userId()))

  Template.mypastes.helpers
    parse: (paste) ->
      if paste.split(' ').length > 1 or /\<|\>|'|"/.test(paste)
        return paste
      if /^http/.test paste
        return new Handlebars.SafeString("<a href='#{paste}'>#{paste}</a>")
      return paste

  Template.mypastes.events
    'click #private': (e) ->
        paste = Pastes.findOne({username: Session.get("username")})
        Pastes.update paste._id, {$set: {privateTo: Meteor.userId()}}


  Template.mypastes.result = ->
    r = Pastes.findOne(username: Session.get "username")
    r.pastes.reverse() if r?
    return r
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
      pastes = Pastes.find(username: username).count()
      if pastes > 0
        Pastes.update({username: username},
                      {$push: {pastes: paste}},
                      {multi: true})
      else
        Pastes.insert
          username: username
          pastes: [paste]
      return false

  Meteor.startup ->
    Backbone.history.start(pushState: true)
