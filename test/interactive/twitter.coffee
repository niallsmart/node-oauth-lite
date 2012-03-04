interactive = require('./interactive')

endpoints =
	request: "https://api.twitter.com/oauth/request_token"
	authorize: "https://api.twitter.com/oauth/authorize"
	access: "https://api.twitter.com/oauth/access_token"

state =
	oauth_consumer_key: "YOEELb7vpsH73W11JAyy1A"
	oauth_consumer_secret: "U7YpvrgWMONdiDCawBhB75dt3iC5qjxaFusPJzG8"

class TwitterTest extends interactive.InteractiveTest

	onSuccess: (params) ->

		@state.oauth_token = params.oauth_token
		@state.oauth_token_secret = params.oauth_token_secret

		this.fetchAndLog "https://api.twitter.com/1/account/verify_credentials.xml"

test = new TwitterTest(endpoints, state)
test.run()




