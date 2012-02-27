oauth = require('../src/http')
urllib = require('url')
assert = require('nodeunit/lib/assert')

exports.testMakeAuthorizationHeader = (test) ->
  state =
    oauth_consumer_key: "0b2eb1469"
    oauth_consumer_secret: "b0cae9f3b7"
    oauth_callback: "oob"
    oauth_nonce: "d1fdf5bd8d4"
    oauth_timestamp: "1329806281"

  options = urllib.parse("https://api.twitter.com/oauth/request_token", true)
  options.method = "POST"

  header = oauth.makeAuthorizationHeader state, options

  test.equal header, 'OAuth oauth_consumer_key="0b2eb1469",oauth_callback="oob",oauth_nonce="d1fdf5bd8d4",oauth_timestamp="1329806281",oauth_version="1.0",oauth_signature_method="HMAC-SHA1",oauth_signature="16Wu6JCHalUvrIgD31sOX7M%2F%2F60%3D"'
  test.done()


exports.testFetchRequestTokenBadProtocol = (test) ->

  state = 
    oauth_consumer_key: "abcd"
    oauth_consumer_secret: "efgh"
    oauth_callback: "http://client.com/oauth/callback"

  try 
    oauth.fetchRequestToken state, "http://service.net/oauth/request", null
    test.ok false, "expected exception"
  catch e
    test.equal e.message, "OAuthconnection requires https; http was specified"

  test.done() 


exports.testFetchRequestTokenGoogle = (test) ->

  state =
    oauth_consumer_key: "anonymous"
    oauth_consumer_secret: "anonymous"
    oauth_callback: "oob"

  request = urllib.parse("https://www.google.com/accounts/OAuthGetRequestToken", true)

  form =
      xoauth_displayname: "OAuth Lite"
      scope: "http://www.google.com/calendar/feeds http://picasaweb.google.com/data"

  test.expect(4)

  oauth.fetchRequestToken state, request, form, (err, params) ->
    test.equal err, null
    test.equal params.oauth_callback_confirmed, "true"
    test.ok params.oauth_token?
    test.ok params.oauth_token_secret?
    test.done()


#exports.testFetchAccessToken = (test) ->
#  dummy = https


exports.testFetchRequestTokenRequiredParameters = (test) ->

  state = 
    oauth_consumer_key: null
    oauth_consumer_secret: null

  try 
    oauth.fetchRequestToken state, "https://service.net/oauth/request", null
    test.ok false, "expected exception"
  catch e
    test.equal e.message, "state.oauth_consumer_key is required"

  state.oauth_consumer_key = "abcd"

  try 
    oauth.fetchRequestToken state, "https://service.net/oauth/request", null
    test.ok false, "expected exception"
  catch e
    test.equal e.message, "state.oauth_consumer_secret is required"

  test.done()
