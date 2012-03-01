interactive = require('./interactive')
oauth = require('../../src/http')
urllib = require('url')
request = require('request')

endpoints =
	request: "http://api.netflix.com/oauth/request_token"
	authorize: "https://api-user.netflix.com/oauth/login"
	access: "http://api.netflix.com/oauth/access_token"

state =
	oauth_consumer_key: "dnejxnzaqed4q7635zdrjgch"
	oauth_consumer_secret: "UEt79uW6z5"

oauth.requireTLS = false

class NetflixTest extends interactive.InteractiveTest

	constructor: ->
		super(endpoints, state)

	makeAuthorizeUrl: (params) ->
		url = urllib.parse(@endpoints.authorize, true)
		url.query.oauth_token = params.oauth_token
		url.query.oauth_consumer_key = @state.oauth_consumer_key
		urllib.format(url)

	onSuccess: (params) ->

		@state.oauth_token = params.oauth_token
		@state.oauth_token_secret = params.oauth_token_secret

		options = "http://api.netflix.com/users/#{params.user_id}?output=json"
		options = urllib.parse(options, true);
		options.url = options
		options.method = "GET"
		options.headers =
			"Authorization":	oauth.makeAuthorizationHeader(@state, options)

		request options, (error, response, body) ->

			if (!error)
   				console.log("HTTP #{response.statusCode}:")
   				console.log(body)
			else
				console.log error
				process.exit(1)

test = new NetflixTest
test.run()




