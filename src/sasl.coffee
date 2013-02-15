urllib = require("url")
prim = require("./prim")

exports.makeClientInitialResponse = (state, options) ->

  eql = (k, v) ->
    "#{k}=#{v}"

  quote = (v) ->
    "\"#{v}\""

  params = prim.makeOAuthParameters(state, options)
  keys = (k for own k of params).sort()
  params = for k in keys
    eql(prim.encode(k), quote(prim.encode(params[k])))

  b = new Buffer("GET #{urllib.format(options)} #{params.join(",")}")
  b.toString("base64")



