# Introduction


node-oauth-lite is a lightweight OAuth 1.0a client library for Node.js. It's designed
for use with any HTTP client library, and supports Google's [XOAUTH mechanism]
(https://developers.google.com/google-apps/gmail/oauth_protocol)
for SMTP and IMAP authentication.

# Example Usage

### Fetching a Request Token

```coffee
oauth = require("oauth-lite")

state =
  oauth_consumer_key: 'anonymous'       # Google do not require pre-registration of OAuth clients
  oauth_consumer_secret: 'anonymous'
  oauth_callback: 'oob'                 # A web-app would usually provide the provider a callback URL instead.

url = 'https://www.google.com/accounts/OAuthGetRequestToken'

form =                                   # Additional request parameters specific to Google's API
  xoauth_displayname: 'node-oauth-lite'
  scope: 'https://www.googleapis.com/auth/userinfo#email'     

oauth.fetchRequestToken state, url, form, (err, params) ->
  # if the request was successful, the temporary request token
  # is supplied as params.oauth_token and params.oauth_token_secret

```

### Authorizing a Request Token

Once a temporary request token has been generated, the user must authorize access. Usually this involves
redirecting the user to an authorization page on the service provider specifying the 
request token as a query parameter.

If the user grants access, the service provider will provide a verification code (either via a
confirmation page or HTTP callback to the client, depending on the `oauth_callback` parameter above) and
then the request token can then be exchanged for a permanent access token.

### Exchanging an authorized Request Token for an Access Token

```coffee
state =
  oauth_consumer_key: 'anonymous'
  oauth_consumer_secret: 'anonymous'
  oauth_token: '<AUTHORIZED-REQUEST-TOKEN>'
  oauth_token_secret: '<AUTHORIZED-REQUEST-TOKEN-SECRET>'
  oauth_verifier: '<VERIFICATION-CODE-FROM-CALLBACK>'

url = 'https://www.google.com/accounts/OAuthGetAccessToken'

oauth.fetchAccessToken state, url, null, (err, params) =>
  # if the request was successful, the permanent access token
  # is supplied as params.oauth_token and params.oauth_token_secret

```

### Using an Access Token

The access token can now be used to make authorized HTTP requests to the service provider
on behalf of the user. Requests must include the Authenticate" header as generated
by the `oauth.makeAuthorizationHeader` API.

```coffee
https = require('https')
urllib = require('url')
oauth = require('oauth-lite')

state =
  oauth_consumer_key: 'anonymous'
  oauth_consumer_secret: 'anonymous'
  oauth_token: '<USERS-ACCESS-TOKEN>'
  oauth_token_secret: '<USERS-ACCESS-TOKEN-SECRET>'
  
url = 'https://www.googleapis.com/userinfo/email'

options = urllib.parse(url, true);
options.url = options
options.method = 'GET'
options.headers =
  'Authorization': oauth.makeAuthorizationHeader(state, options)

https.get options, (response) ->
  response.on 'data', (chunk) ->
    console.log('DATA: ' + chunk)
```

# XOAuth Support

An access token can also be used to authenticate to SMTP and IMAP servers using Google's [XOAUTH mechanism]
(https://developers.google.com/google-apps/gmail/oauth_protocol).

```coffee
urllib = require('url')
oauth = require('oauth-lite')
Imap = require('imap')

state =
  oauth_consumer_key: 'anonymous'
  oauth_consumer_secret: 'anonymous'
  oauth_token: '<USERS-ACCESS-TOKEN>'
  oauth_token_secret: '<USERS-ACCESS-TOKEN-SECRET>'

email = '<USERS-EMAIL>'
url = "https://mail.google.com/mail/b/#{email}/imap/"

options = urllib.parse(url)
options.method = "GET"
icr = oauth.makeClientInitialResponse(state, options)

imap = new Imap(
  xoauth: icr
  host: 'imap.gmail.com',
  port: 993,
  secure: true
)

imap.connect (err) ->
  if (err)
    console.log("IMAP connect failed", err)
    return
  console.log("connected to IMAP server")
  imap.openBox 'INBOX', true, (err, info) ->
    if (!err)
      console.log("#{info.messages.total} messages(s) in INBOX");
    imap.logout();
```

# Reference

 * [RFC 5849](http://tools.ietf.org/html/rfc5849) defines OAuth 1.0.

# Tests

If you have't already done so, globally install nodeunit first with `npm install -g nodeunit` then run `cake test` to run the unit tests.

Interactive tests for some common OAuth service providers are in `tests/interactive`.
