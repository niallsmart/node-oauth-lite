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
	scope: "http://www.google.com/calendar/feeds"

class GoogleTest extends interactive.InteractiveTest

test = new GoogleTest
test.run()

