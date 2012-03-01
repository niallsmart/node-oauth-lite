interactive = require('./interactive')

endpoints =
	request: "https://www.google.com/accounts/OAuthGetRequestToken"
	authorize: "https://www.google.com/accounts/OAuthAuthorizeToken"
	access: "https://www.google.com/accounts/OAuthGetAccessToken"

state =
	oauth_consumer_key: "anonymous"
	oauth_consumer_secret: "anonymous"

form =
	xoauth_displayname: "OAuth Lite"
	scope: "http://www.google.com/calendar/feeds http://picasaweb.google.com/data"

class GoogleTest extends interactive.InteractiveTest

	constructor: ->
		super(endpoints, state, form)

test = new GoogleTest
test.run()

