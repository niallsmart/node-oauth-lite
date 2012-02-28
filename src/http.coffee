#
# OAuth HTTP support.
#

events = require('events');
urllib = require('url')
qslib = require('querystring')
https = require('https')
prim = require('./prim')
oauth = exports

clone = (obj) ->
  ret = {}
  ret[k] = v for own k, v of obj
  ret

fetchToken = (state, options, form, cb) ->

  if typeof(options) == 'string'
    options = urllib.parse(options, true)
  
  options.method ?= "POST"
  options.headers ?= {}
  options.headers["Authorization"] = oauth.makeAuthorizationHeader state, options, form, options.realm



  if options.protocol != 'https:'
    throw new Error("OAuthconnection requires https; #{options.protocol.slice(0, -1)} was specified") 

  if form?
    form = qslib.stringify(form) if typeof(form) == 'object'
    options.headers["Content-Length"] = form.length 
    options.headers["Content-Type"] = "application/x-www-form-urlencoded"
  else
    options.headers["Content-Length"] = 0

  req = https.request options, (res) ->

    if (res.statusCode != 200) 
      cb(new Error("server responded with HTTP #{res.statusCode}"))
      return

    # As of 2/2012, Google does not set the correct Content-Type, so
    # we ignore the headers and assume "application/x-www-form-urlencoded"

    buf = ""

    res.setEncoding 'utf8'

    res.on 'data', (data) ->
      buf += data
        
    res.on 'end', () ->
      params = qslib.parse(buf)
      cb(null, params)

  req.on 'error', (e) ->
    cb(e)

  if form?
    req.write(form);

  req.end();


#
# Fetches a request token ("temporary credentials") from the specified
# URL.
#
# @param oauth object with oauth_consumer_key, oauth_consumer_secret, oauth_callback
# @param URL string or object specification of URL
# @param [form] form parameters to include in request ('application/x-www-form-urlencoded')
# 
oauth.fetchRequestToken = (state, options, form, cb) ->

  if (typeof(form) == 'function')
    cb = form
    form = null

  required = ["oauth_consumer_key", "oauth_consumer_secret"]

  for prop in required
    if !state[prop]?
      throw new Error("state.#{prop} is required")

  fetchToken state, options, form, (err, params) ->

    if (err) 
      cb(err)
      return

    if params.oauth_callback_confirmed != 'true'
      cb(new Error("expected oauth_callback_confirmed=true"))
      return

    if !params.oauth_token?
      cb(new Error("response does not contain oauth_token"))
      return

    if !params.oauth_token_secret?
      cb(new Error("response does not contain oauth_token_secret"))
      return

    cb(null, params)


#
# Fetches an access token ("token credentials") from the specified URL.
#
# @param oauth object with oauth_consumer_key, oauth_consumer_secret, oauth_token, oauth_token_secret, oauth_verifier
# @param URL string or object specification of URL
# @param [form] form parameters to include in request ('application/x-www-form-urlencoded')
# 
oauth.fetchAccessToken = (state, options, form, cb) ->

  if (typeof(form) == 'function')
    cb = form
    form = null

  required = ["oauth_consumer_key", "oauth_consumer_secret", "oauth_token", "oauth_token_secret", "oauth_verifier"]

  for prop in required
    if !state[prop]?
      throw new Error("state.#{prop} is required")

  if typeof(options) == 'string'
    options = urllib.parse(options, true)
  
  fetchToken state, options, form, (err, params) ->

    if (err) 
      cb(err)
      return

    if !params.oauth_token?
      cb(new Error("response does not contain oauth_token"))
      return

    if !params.oauth_token_secret?
      cb(new Error("response does not contain oauth_token_secret"))
      return

    cb(null, params)


oauth.makeAuthorizationHeader = (state, options, form, realm) ->

  eql = (k, v) ->
    "#{k}=#{v}"

  quote = (v) ->
    "\"#{v}\""

  params = prim.makeOAuthParameters(state, options, form)
  header = "OAuth "

  params = for own k, v of params
    eql(prim.encode(k), quote(prim.encode(v)))

  if realm?
    realm = realm.replace /"/g, "\\\""
    params.splice(0, 0, eql("realm", quote(realm)))

  header += params.join(",")
  header



