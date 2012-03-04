interactive = require('./interactive')
oauth = require('../../src/http')
urllib = require('url')

endpoints =
	request: "http://api.netflix.com/oauth/request_token"
	authorize: "https://api-user.netflix.com/oauth/login"
	access: "http://api.netflix.com/oauth/access_token"

state =
	oauth_consumer_key: "dnejxnzaqed4q7635zdrjgch"
	oauth_consumer_secret: "UEt79uW6z5"

oauth.requireTLS = false

class NetflixTest extends interactive.InteractiveTest

	makeAuthorizeUrl: (params) ->
		# NetFlix's API requires clients to send the oauth_consumer_key
		# when authorizing the request token.
		url = urllib.parse(@endpoints.authorize, true)
		url.query.oauth_token = params.oauth_token
		url.query.oauth_consumer_key = @state.oauth_consumer_key
		urllib.format(url)

	onSuccess: (params) ->

		@state.oauth_token = params.oauth_token
		@state.oauth_token_secret = params.oauth_token_secret

		this.fetchAndLog "http://api.netflix.com/users/#{params.user_id}?output=json"

test = new NetflixTest(endpoints, state)
test.run()




