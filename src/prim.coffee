#
# OAuth primitives.
#

urllib = require('url')
qslib = require('querystring')
crypto = require('crypto')
oa = exports

oa.defaultPorts = {
  "http:":   80,
  "https:":  443
}

oa.defaultNonceBytes = 32

#
# Creates an OAuth signature base string for a HTTP request.
#
# @param oauth OAuth parameters included with this request (object) (optional)
# @param url request URL including protocol, hostname, path and query string parameters (as string or object) 
# @param form HTTP body form data (as "application/x-www-form-urlencoded" string or object) (optional)
#
oa.makeSignatureBaseString = (oauth, request, form) ->

  form = qslib.parse(form) if typeof(form) == 'string'

  [oa.makeSignatureMethod(request.method),
    oa.makeSignatureURL(request),
    oa.makeSignatureParameters(oauth, request.query, form)].join("&")


oa.makeSignatureMethod = (method) ->
  oa.encode(method.toUpperCase())


oa.makeSignatureURL = (request) ->
  scheme = request.protocol.toLowerCase()
  hostname = request.hostname.toLowerCase()
  port = if !request.port || parseInt(request.port, 10) == oa.defaultPorts[scheme] then "" else ":#{request.port}"
  pathname = request.pathname || "/"
  oa.encode("#{scheme}//#{hostname}#{port}#{pathname}")


oa.makeSignatureParameters = (oauth, queryString, form) ->
  params = []

  collect = (obj) ->
    for own k, vs of obj
      vs = [vs] unless vs instanceof Array
      for v in vs
        params.push({key: oa.encode(k), value: oa.encode(v)})

  collect(oauth)
  collect(queryString)
  collect(form)

  params.sort (l, r) ->
    field = if l.key == r.key then "value" else "key"
    l[field].localeCompare(r[field])

  params = params.map (kv) ->
    "#{kv.key}=#{kv.value}"

  oa.encode(params.join("&"))


oa.encode = (str) ->
  ret = encodeURIComponent(str)
  ret = ret.replace(/!/g, '%21')
  ret = ret.replace(/'/g, '%27')
  ret = ret.replace(/\(/g, '%28')
  ret = ret.replace(/\)/g, '%29')
  ret = ret.replace(/\*/g, '%2A');
  ret


oa.makeNonce = (bytes) ->
  crypto.randomBytes(bytes || oa.defaultNonceBytes).toString('hex')


oa.makeTimestamp = ->
  Math.floor(Date.now() / 1000).toString()


oa.signHmac = (clientSecret, tokenSecret, oauth, request, form) ->
  key = [oa.encode(clientSecret), oa.encode(tokenSecret || "")].join("&")
  sbs = oa.makeSignatureBaseString(oauth, request, form) #unless typeof(request) == 'string'
  hmac = crypto.createHmac("sha1", key)
  hmac.update(sbs)
  hmac.digest("base64")


oa.makeOAuthParameters = (state, request, form) ->
  oauth = {}
  oauth.oauth_consumer_key = state.oauth_consumer_key
  oauth.oauth_token = state.oauth_token if state.oauth_token?
  oauth.oauth_verifier = state.oauth_verifier if state.oauth_verifier?
  oauth.oauth_callback = state.oauth_callback if state.oauth_callback?
  oauth.oauth_nonce = state.oauth_nonce || oa.makeNonce()
  oauth.oauth_timestamp = state.oauth_timestamp || oa.makeTimestamp()
  oauth.oauth_version = "1.0"
  oauth.oauth_signature_method = "HMAC-SHA1"
  oauth.oauth_signature = oa.signHmac(
      state.oauth_consumer_secret,
      state.oauth_token_secret,
      oauth,
      request,
      form
  )
  oauth