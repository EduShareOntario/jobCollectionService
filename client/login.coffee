#Template.ldapLogin2.replaces "ldapLogin"
#Template.ldapLogin2.inheritsHelpersFrom "ldapLogin"

Template.ldapLogin2.onCreated () ->
  this.loginFailed = new ReactiveVar(false)

Template.ldapLogin2.events = {
  'click button[name="login2"]': (e, tpl) ->
    initLogin2 e, tpl

  'keyup input': (e, tpl) ->
    if (e.keyCode == 13) #If Enter Key Pressed
      initLogin2 e, tpl

  'click button[name="logout"]': (e) ->
    Template.instance().loginFailed.set(false)
    Meteor.logout()
}

Meteor.loginWithLdap2 = (username, password, callback) ->
  Accounts.callLoginMethod {
    methodArguments: [{
      username: username,
      pass: password,
      ldap: true
    }]
    ,
    validateResult: (result) ->
      console.log result
      console.log result
    ,
    userCallback: callback
  }

Template.ldapLogin2.helpers
  loginFailed: () ->
    return Template.instance().loginFailed.get()


# Initiate Login Process:
initLogin2 = (e, tpl) ->
  tpl.loginFailed.set(false)
  username = $(tpl.find('input[name="ldap"]')).val();
  password = $(tpl.find('input[name="password"]')).val();
  Meteor.loginWithLdap2 username, password, (result) ->
    console.log JSON.stringify(result)
    if (Meteor.userId())
      tpl.loginFailed.set(false)
    else
      tpl.loginFailed.set(true)
