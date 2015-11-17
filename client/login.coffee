Template.ldapLogin2.onCreated () ->
  this.loginFailed = new ReactiveVar(false)

Template.ldapLogin2.events = {
  'click button[name="login2"]': (e, tpl) ->
    initLogin2 e, tpl

  'keyup input': (e, tpl) ->
    if (e.keyCode == 13) #If Enter Key Pressed
      initLogin2 e, tpl
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
    ,
    userCallback: callback
  }

Template.ldapLogin2.helpers
  loginFailed: () ->
    failed = Template.instance().loginFailed.get()
    #console.log "loginFailed: #{failed}"
    return failed

  unauthorized: () ->
    failed = Template.instance().loginFailed.get()
    authorized = Meteor.user()?.memberOf?.length > 0
    redirect = Session.get 'redirectAfterLogin'
    return !failed and redirect and !(authorized)


# Initiate Login Process:
initLogin2 = (e, tpl) ->
  username = $(tpl.find('input[name="ldap"]')).val().trim();
  password = $(tpl.find('input[name="password"]')).val().trim();
  if username.length == 0 or password.length == 0
    tpl.loginFailed.set true
  else
    tpl.loginFailed.set(false)
    Meteor.loginWithLdap2 username, password, (result) ->
      #console.log JSON.stringify(result)
      if (result && result.error)
        tpl.loginFailed.set(true)
