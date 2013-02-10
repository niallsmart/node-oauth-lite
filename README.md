# Introduction


node-oauth-lite is a lightweight OAuth 1.0a client library for Node.js. It's designed
for use with any HTTP client library, and supports Google's [XOAUTH mechanism]
(https://developers.google.com/google-apps/gmail/oauth_protocol)
for SMTP and IMAP authentication.

# Example Usage

### Fetching a Request Token

```coffee
state =
  oauth_consumer_key = 'anonymous'       # Google do not require pre-registration of OAuth clients
  oauth_consumer_secret = 'anonymous'
  oauth_callback = 'oob'                 # A web-app would usually provide the provider a callback URL instead.

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
  oauth_consumer_key = 'anonymous'
  oauth_consumer_secret = 'anonymous'
  oauth_token = '<AUTHORIZED-REQUEST-TOKEN>'
  oauth_token_secret = '<AUTHORIZED-REQUEST-TOKEN-SECRET>'
  oauth_verifier = '<VERIFICATION-CODE-FROM-CALLBACK>'

url = 'https://www.google.com/accounts/OAuthGetAccessToken'

oauth.fetchAccessToken state, access_url, null, (err, params) =>
  # if the request was successful, the permanent access token
  # is supplied as params.oauth_token and params.oauth_token_secret

```

### Using an Access Token

The access token can now be used to make authorized HTTP requests to the service provider
on behalf of the user. Requests must include the Authenticate" header as generated
by the `oauth.makeAuthorizationHeader` API.

```coffee
urllib = require('url')
request = require('request')

state =
  oauth_consumer_key = 'anonymous'
  oauth_consumer_secret = 'anonymous'
  oauth_token = '<USERS-ACCESS-TOKEN>'
  oauth_token_secret = '<USERS-ACCESS-TOKEN-SECRET>'
  
url = 'https://www.googleapis.com/userinfo/email'

options = urllib.parse(url, true);
options.url = options
options.method = 'GET'
options.headers =
  'Authorization':	oauth.makeAuthorizationHeader(@state, options)

  request options, (error, response, body) ->
    # user's email address should be in `body`
```

# XOAuth Support

TODO

# Reference

 * [RFC 5849](http://tools.ietf.org/html/rfc5849) defines OAuth 1.0.

# Tests

If you have't already done so, globally install nodeunit first with `npm install -g nodeunit` then run `cake test` to run the unit tests.

Interactive tests for some common OAuth service providers are in `tests/interactive`.
