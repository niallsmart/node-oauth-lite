#
# OAuth utilitives.
#

urllib = require('url')
qslib = require('querystring')
crypto = require('crypto')
util = exports

util.defaultPorts = {
  "http:":   80,
  "https:":  443
}

util.defaultNonceBytes = 32

#
# Creates an OAuth signature base string for a HTTP request.
#
# @param oauth OAuth parameters included with this request (object) (optional)
# @param url request URL including protocol, hostname, path and query string parameters (as string or object) 
# @param form HTTP body form data (as "application/x-www-form-urlencoded" string or object) (optional)
#
util.makeSignatureBaseString = (oauth, request, form) ->

  form = qslib.parse(form) if typeof(form) == 'string'

  [util.makeSignatureMethod(request.method),
    util.makeSignatureURL(request),
    util.makeSignatureParameters(oauth, request.query, form)].join("&")


util.makeSignatureMethod = (method) ->
  util.encode(method.toUpperCase())


util.makeSignatureURL = (request) ->
  scheme = request.protocol.toLowerCase()
  hostname = request.hostname.toLowerCase()
  port = if !request.port || parseInt(request.port, 10) == util.defaultPorts[scheme] then "" else ":#{request.port}"
  pathname = request.pathname || "/"
  util.encode("#{scheme}//#{hostname}#{port}#{pathname}")


util.makeSignatureParameters = (oauth, queryString, form) ->
  queryString = qslib.parse(queryString) if typeof(queryString) == 'string'
  params = []

  collect = (obj) ->
    for own k, vs of obj
      vs = [vs] unless vs instanceof Array
      for v in vs
        params.push({key: util.encode(k), value: util.encode(v)})

  collect(oauth)
  collect(queryString)
  collect(form)

  params.sort (l, r) ->
    field = if l.key == r.key then "value" else "key"
    l[field].localeCompare(r[field])

  params = params.map (kv) ->
    "#{kv.key}=#{kv.value}"

  util.encode(params.join("&"))


util.encode = (str) ->
  ret = encodeURIComponent(str)
  ret = ret.replace(/!/g, '%21')
  ret = ret.replace(/'/g, '%27')
  ret = ret.replace(/\(/g, '%28')
  ret = ret.replace(/\)/g, '%29')
  ret = ret.replace(/\*/g, '%2A');
  ret


util.makeNonce = (bytes) ->
  crypto.randomBytes(bytes || util.defaultNonceBytes).toString('hex')


util.makeTimestamp = ->
  Math.floor(Date.now() / 1000).toString()


util.signHmac = (clientSecret, tokenSecret, oauth, request, form) ->
  key = [util.encode(clientSecret), util.encode(tokenSecret || "")].join("&")
  sbs = util.makeSignatureBaseString(oauth, request, form)
  hmac = crypto.createHmac("sha1", key)
  hmac.update(sbs)
  hmac.digest("base64")


util.makeOAuthParameters = (state, request, form) ->
  oauth = {}
  oauth.oauth_consumer_key = state.oauth_consumer_key
  oauth.oauth_token = state.oauth_token if state.oauth_token?
  oauth.oauth_verifier = state.oauth_verifier if state.oauth_verifier?
  oauth.oauth_callback = state.oauth_callback if state.oauth_callback?
  oauth.oauth_nonce = state.oauth_nonce || util.makeNonce()
  oauth.oauth_timestamp = state.oauth_timestamp || util.makeTimestamp()
  oauth.oauth_version = "1.0"
  oauth.oauth_signature_method = "HMAC-SHA1"
  oauth.oauth_signature = util.signHmac(
      state.oauth_consumer_secret,
      state.oauth_token_secret,
      oauth,
      request,
      form
  )
  oauth
