oauth = require("../src/main")
urllib = require("url")

exports.testMakeAuthorizationHeader = (test) ->
  state =
    oauth_consumer_key: "oranges"
    oauth_consumer_secret: "bananas"
    oauth_token: "apples"
    oauth_token_secret: "grapes"
    oauth_nonce: "1695809739888782035"
    oauth_timestamp: "1360904451"

  options = urllib.parse("https://mail.google.com/mail/b/someone@example.com/imap/", true)
  options.method = "GET"

  icr = oauth.makeClientInitialResponse state, options
  test.equal icr, """
    R0VUIGh0dHBzOi8vbWFpbC5nb29nbGUuY29tL21haWwvYi9zb21lb25lQGV4YW1wbGUuY29tL2ltYXAvIG9hdXRoX2NvbnN1bWVyX2tleT0ib3JhbmdlcyIsb2F1dGhfbm9uY2U9IjE2OTU4MDk3Mzk4ODg3ODIwMzUiLG9hdXRoX3NpZ25hdHVyZT0iM0RNSVhabEpob3U3Qm1pUFdob0YwNU5TYURJJTNEIixvYXV0aF9zaWduYXR1cmVfbWV0aG9kPSJITUFDLVNIQTEiLG9hdXRoX3RpbWVzdGFtcD0iMTM2MDkwNDQ1MSIsb2F1dGhfdG9rZW49ImFwcGxlcyIsb2F1dGhfdmVyc2lvbj0iMS4wIg==
  """.replace(/\s+/g, "")

  test.done()






