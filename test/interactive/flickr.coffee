interactive = require('./interactive')
oauth = require('../../src/http')
urllib = require('url')
request = require('request')

endpoints =
	request: "https://secure.flickr.com/services/oauth/request_token"
	authorize: "https://secure.flickr.com/services/oauth/authorize"
	access: "https://secure.flickr.com/services/oauth/access_token"

state =
	oauth_consumer_key: "cc212e64e756e23f3313897fe0fc8117"
	oauth_consumer_secret: "19ee002635f3223e"

class FlickrTest extends interactive.InteractiveTest

	onSuccess: (params) ->

		@state.oauth_token = params.oauth_token
		@state.oauth_token_secret = params.oauth_token_secret

		this.fetchAndLog "http://api.flickr.com/services/rest/?method=flickr.test.login&nojsoncallback=1&format=json"

test = new FlickrTest(endpoints, state)
test.run()




