oauth = require('../src/main')
util = require('../src/util')
urllib = require('url')
fslib = require('fs');
qslib = require('querystring');
assert = require('nodeunit/lib/assert')
https = require('https');

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
  test.equal header, 'OAuth oauth_callback="oob",oauth_consumer_key="0b2eb1469",oauth_nonce="d1fdf5bd8d4",' +
                      'oauth_signature="16Wu6JCHalUvrIgD31sOX7M%2F%2F60%3D",oauth_signature_method="HMAC-SHA1",' +
                      'oauth_timestamp="1329806281",oauth_version="1.0"'

  header = oauth.makeAuthorizationHeader state, options, null, 'Admin "A"!'
  test.equals header, 'OAuth realm="Admin \\"A\\"!",oauth_callback="oob",oauth_consumer_key="0b2eb1469",oauth_nonce="d1fdf5bd8d4",' +
                      'oauth_signature="16Wu6JCHalUvrIgD31sOX7M%2F%2F60%3D",oauth_signature_method="HMAC-SHA1",' +
                      'oauth_timestamp="1329806281",oauth_version="1.0"'

  header = oauth.makeAuthorizationHeader state, options, null, ''
  test.equal header, 'OAuth realm="",oauth_callback="oob",oauth_consumer_key="0b2eb1469",oauth_nonce="d1fdf5bd8d4",' +
                      'oauth_signature="16Wu6JCHalUvrIgD31sOX7M%2F%2F60%3D",oauth_signature_method="HMAC-SHA1",' +
                      'oauth_timestamp="1329806281",oauth_version="1.0"'

  test.done()


exports.testMakeAuthorizationHeaderWithoutParsingQueryString = (test) ->
  state =
    oauth_consumer_key: "0b2eb1469"
    oauth_consumer_secret: "b0cae9f3b7"
    oauth_callback: "oob"
    oauth_nonce: "d1fdf5bd8d4"
    oauth_timestamp: "1329806281"

  options = urllib.parse("https://api.twitter.com/oauth/request_token?foo=bar")
  options.method = "POST"

  header = oauth.makeAuthorizationHeader state, options
  test.equal header, 'OAuth oauth_callback="oob",oauth_consumer_key="0b2eb1469",oauth_nonce="d1fdf5bd8d4",' +
                      'oauth_signature="erdbNVCT%2FVbdzY4Q3xOuJxFoBt4%3D",oauth_signature_method="HMAC-SHA1",' +
                      'oauth_timestamp="1329806281",oauth_version="1.0"'

  header = oauth.makeAuthorizationHeader state, options, null, 'Admin "A"!'
  test.equals header, 'OAuth realm="Admin \\"A\\"!",oauth_callback="oob",oauth_consumer_key="0b2eb1469",oauth_nonce="d1fdf5bd8d4",' +
                      'oauth_signature="erdbNVCT%2FVbdzY4Q3xOuJxFoBt4%3D",oauth_signature_method="HMAC-SHA1",' +
                      'oauth_timestamp="1329806281",oauth_version="1.0"'

  header = oauth.makeAuthorizationHeader state, options, null, ''
  test.equal header, 'OAuth realm="",oauth_callback="oob",oauth_consumer_key="0b2eb1469",oauth_nonce="d1fdf5bd8d4",' +
                      'oauth_signature="erdbNVCT%2FVbdzY4Q3xOuJxFoBt4%3D",oauth_signature_method="HMAC-SHA1",' +
                      'oauth_timestamp="1329806281",oauth_version="1.0"'

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
    test.equal e.message, "http not supported (try https, or set requireTLS=false)"

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


exports.testWithMockServer = (test) ->

  # mock OAuth server setup
  mock =
    keys:
      key: fslib.readFileSync('./test/server-key.pem'),
      cert: fslib.readFileSync('./test/server-cert.pem')
    port: 8111
    request:
      url:
        "/oauth/request?log=true"
      form:
        animal: "cat"
      response:
        oauth_token: "foo"
        oauth_token_secret: "bar"
        oauth_callback_confirmed: "true"
    access:
      url:
        "/oauth/access?log=true"
      form:
        animal: "dog"
      response:
        oauth_token: "baz"
        oauth_token_secret: "qux"
      oauth_token: "baz"
      oauth_token_secret: "qux"

  # mock OAuth server
  server = https.createServer mock.keys, (req, res) ->

    test.equal req.method, options.method
    test.equal req.headers["content-type"], "application/x-www-form-urlencoded"
    test.equal req.headers["authorization"], authorization

    switch req.url
      when mock.request.url
        xchg = mock.request
      when mock.access.url
        xchg = mock.access
      else
        test.ok false, "unexpected URL: #{req.url}"

    req.setEncoding 'utf8'
    req.on 'data', (buf) ->
      test.equals req.headers["content-length"], buf.length
      test.equals buf, qslib.encode(xchg.form)
      form = qslib.encode(xchg.response)
      res.setHeader("Content-Length", form.length)
      res.setHeader("Content-Type", "application/x-www-form-urlencoded")
      res.writeHead(200)
      res.end(form)

  state = 
    oauth_consumer_key: "QAFNTS138L"
    oauth_consumer_secret: "TOMII7Q9E6"
    oauth_callback: "http://client.com/oauth/callback"
    oauth_nonce: util.makeNonce()
    oauth_timestamp: util.makeTimestamp()

  options = urllib.parse("https://localhost:#{mock.port}#{mock.request.url}", true)
  options.method = "POST"
  options.realm = "Test"

  test.expect 15

  authorization = oauth.makeAuthorizationHeader state, options, mock.request.form, "Test"

  server.listen mock.port, 'localhost', () ->

    oauth.fetchRequestToken state, options, mock.request.form, (err, params) ->

      test.equal err, null
      test.deepEqual params, mock.request.response

      state.oauth_token = params.oauth_token
      state.oauth_token_secret = params.oauth_token_secret 
      state.oauth_verifier = "7C62GLI1TK"

      options = urllib.parse("https://localhost:#{mock.port}#{mock.access.url}", true)
      options.method = "POST"
      options.realm = "Test"

      authorization = oauth.makeAuthorizationHeader state, options, mock.access.form, "Test"

      oauth.fetchAccessToken state, options, mock.access.form, (err, params) ->
        test.equal err, null
        test.equal params.oauth_token, mock.access.response.oauth_token
        test.equal params.oauth_token_secret, mock.access.response.oauth_token_secret
        server.close()
        test.done()






