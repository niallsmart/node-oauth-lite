oa = require('../src/prim')
urllib = require('url')
assert = require('nodeunit/lib/assert')

#
# TODO: unwrap escaping in test cases for legibility.
#

exports.testMakeSignatureMethod = (test) ->
  test.equal oa.makeSignatureMethod("Get"), "GET"
  test.equal oa.makeSignatureMethod("Zom/Bo"), "ZOM%2FBO"
  test.done()

exports.testMakeSignatureURL = (test) ->
  
  test.signatureURLEqual = (url, expected) ->
    test.equal oa.makeSignatureURL(urllib.parse(url)), expected

  test.signatureURLEqual "HtTp://LocalHost", oa.encode("http://localhost/")
  test.signatureURLEqual "HtTp://LocalHost:80", oa.encode("http://localhost/")
  test.signatureURLEqual "HtTp://LocalHost:080", oa.encode("http://localhost/")
  test.signatureURLEqual "HtTp://LocalHost:8080", oa.encode("http://localhost:8080/")
  test.signatureURLEqual "HtTps://LocalHost", oa.encode("https://localhost/")
  test.signatureURLEqual "HtTps://LocalHost:443", oa.encode("https://localhost/")
  test.signatureURLEqual "HtTps://LocalHost:8443", oa.encode("https://localhost:8443/")
  test.signatureURLEqual "HtTp://LocalHost:80/some/path?q=search#fragment", oa.encode("http://localhost/some/path")
  test.signatureURLEqual "HtTp://LocalHost:80/some/path/", oa.encode("http://localhost/some/path/")
  test.done()

exports.testEncode = (test) ->

  test.encodeEqual = (str, expected) ->
    test.equal oa.encode(str), expected

  # unescaped
  test.encodeEqual "-._~-._~", "-._~-._~"
  # RFC5849/3.6 rules (vs RFC3986)
  test.encodeEqual ":/?#[]@!$&'()*+,;=", "%3A%2F%3F%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D"
  # RFC5849/3.6 rules (url components)
  test.encodeEqual "http://foo:bar@baz/f%o bar?1=2#ok", "http%3A%2F%2Ffoo%3Abar%40baz%2Ff%25o%20bar%3F1%3D2%23ok"
  # four byte UTF-8 sequence
  test.encodeEqual decodeURIComponent("%F0%A4%AD%A2"), "%F0%A4%AD%A2"
  # http://wiki.oauth.net/w/page/12238556/TestCases
  test.encodeEqual "\u0080", "%C2%80"
  test.encodeEqual "\u3001", "%E3%80%81"
  test.done()

exports.testMakeSignatureParameters = (test) ->

  test.signatureParametersEqual = (args, expected) ->

    if typeof(expected) != 'string'
      expected = oa.encode(expected.reduce( (all, pair) ->
        all.concat(pair.map(oa.encode).join("="))
      , []).join("&"))

    test.equal oa.makeSignatureParameters.apply(null, args), expected

  params = [{
    "foo": 12,
    baz: "one"
  }, {
    "%3d=": 3,
    baz: ["two", "t.r*e "]
  }, {
    "foo": "01",
    zorb: ''
  }]

  expected = [
      ["%3d=", "3"],
      ["baz", "one"],
      ["baz", "t.r*e "],
      ["baz", "two"],
      ["foo", "01"],
      ["foo", "12"],
      ["zorb", ""]
  ]

  test.signatureParametersEqual(params, expected)

  # From RFC5489#section-3.4.1.3.2

  params = [{
    "b5": "=%3D",
    "a3": "a",
    "c@": "",
    "a2": "r b"
  }, {
    "oauth_consumer_key": "9djdj82h48djs9d2", 
    "oauth_token": "kkk9d7dh3k39sjv7",
    "oauth_signature_method": "HMAC-SHA1",
    "oauth_timestamp": "137131201",
    "oauth_nonce": "7d8f3e4a"
  }, {
    "c2": "",
    "a3": "2 q"
  }]

  expected = oa.encode("a2=r%20b&a3=2%20q&a3=a&b5=%3D%253D&c%40=&c2=&oauth_consumer_key=9dj" +
                       "dj82h48djs9d2&oauth_nonce=7d8f3e4a&oauth_signature_method=HMAC-SHA1" +
                       "&oauth_timestamp=137131201&oauth_token=kkk9d7dh3k39sjv7")

  test.signatureParametersEqual(params, expected)

  test.done()


exports.testMakeSignatureBaseString = (test) ->
  request = urllib.parse("Http://example.com:80/request?b5=%3D%253D&a3=a&c%40=&a2=r%20b", true);
  request.method = "Post"
  form = "c2&a3=2+q"
  oauth = {
    oauth_consumer_key: "9djdj82h48djs9d2",
    oauth_token: "kkk9d7dh3k39sjv7",
    oauth_signature_method: "HMAC-SHA1",
    oauth_timestamp: "137131201",
    oauth_nonce: "7d8f3e4a"
  }

  sig = oa.makeSignatureBaseString oauth, request, form

  expected = 'POST&http%3A%2F%2Fexample.com%2Frequest&a2%3Dr%2520b%26a3%3D2%2520q' +
   '%26a3%3Da%26b5%3D%253D%25253D%26c%2540%3D%26c2%3D%26oauth_consumer_' +
   'key%3D9djdj82h48djs9d2%26oauth_nonce%3D7d8f3e4a%26oauth_signature_m' +
   'ethod%3DHMAC-SHA1%26oauth_timestamp%3D137131201%26oauth_token%3Dkkk' +
   '9d7dh3k39sjv7'

  test.equal sig, expected
  test.done()


#
# To validate:
#   echo -n zombo | openssl dgst -sha1 -hmac "hello&" -binary | base64
#   echo -n zombo | openssl dgst -sha1 -hmac "%3D&%2F" -binary | base64
#
#exports.testSignHMac = (test) ->
#  sig = oa.signHmac "hello", null, "zombo"
#  test.equal sig, "4Q7qDUw/kAsUfTuFuuf5JV9DP6w="
#  sig = oa.signHmac "=", "/ ", "zombo"
#  test.equal sig, "R5c2ZCw6WAoxO8lOYDpVJ3gZsVE="
#  test.done()


exports.testMakeNonce = (test) ->
  test.equal oa.defaultNonceBytes, 32
  test.ok oa.makeNonce().match(/^[0-9a-zA-Z]{64}$/)
  oa.defaultNonceBytes = 64
  test.ok oa.makeNonce().match(/^[0-9a-zA-Z]{128}$/)
  test.ok oa.makeNonce(4).match(/^[0-9a-zA-Z]{8}$/)
  test.done()


#
# validated against http://developer.netflix.com/resources/OAuthTest
#
exports.testMakeOAuthParameters = (test) ->

  test.assertOAuthParameters = (state, request, expected) ->
    params = oa.makeOAuthParameters state, request

    expected.oauth_signature_method = "HMAC-SHA1"
    expected.oauth_version = "1.0"

    for own k, v of params
      test.equal expected[k], v, "#{k}"

  # request token

  state = 
    oauth_consumer_key: "abcd"
    oauth_consumer_secret: "efgh"
    oauth_timestamp: "1330237492"
    oauth_nonce: "Tsh1xxJTsnR"
    oauth_callback: "http://client.com/oauth/callback"

  request = urllib.parse("http://service.net/oauth/request")
  request.method = "POST"

  expected = 
    oauth_consumer_key: state.oauth_consumer_key
    oauth_timestamp: state.oauth_timestamp
    oauth_nonce: state.oauth_nonce
    oauth_callback: state.oauth_callback
    oauth_signature: "piZGqrk4uvxl38ElgsBEKvRg8qg="

  test.assertOAuthParameters state, request, expected

  # access token
  
  state = 
    oauth_consumer_key: "abcd"
    oauth_consumer_secret: "efgh"
    oauth_token: "ijkl"
    oauth_token_secret: "mnop"
    oauth_timestamp: "1330237492"
    oauth_nonce: "Tsh1xxJTsnR"
    oauth_verifier: "IoQp907Ax4p"

  request = urllib.parse("http://service.net/oauth/access")
  request.method = "POST"

  expected =    
    oauth_consumer_key: state.oauth_consumer_key
    oauth_timestamp: state.oauth_timestamp
    oauth_nonce: state.oauth_nonce
    oauth_verifier: state.oauth_verifier
    oauth_token: state.oauth_token
    oauth_signature: "34uv2/NuDgsHzE3TUy45qCF7mlE="

  test.assertOAuthParameters state, request, expected

  test.done()


