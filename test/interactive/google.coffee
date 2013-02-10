interactive = require('./interactive')

endpoints =
	request: "https://www.google.com/accounts/OAuthGetRequestToken"
	authorize: "https://www.google.com/accounts/OAuthAuthorizeToken"
	access: "https://www.google.com/accounts/OAuthGetAccessToken"

state =
	oauth_consumer_key: "anonymous"
	oauth_consumer_secret: "anonymous"

form =
	xoauth_displayname: "node-oauth-lite"
	scope: "https://www.googleapis.com/auth/userinfo#email"

class GoogleTest extends interactive.InteractiveTest

	onSuccess: (params) ->
		@state.oauth_token = params.oauth_token
		@state.oauth_token_secret = params.oauth_token_secret

		this.fetchAndLog "https://www.googleapis.com/userinfo/email"

test = new GoogleTest(endpoints, state, form)
test.run()

