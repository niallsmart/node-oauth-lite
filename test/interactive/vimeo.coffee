interactive = require('./interactive')

endpoints =
	request: "https://vimeo.com/oauth/request_token"
	authorize: "https://vimeo.com/oauth/authorize"
	access: "https://vimeo.com/oauth/access_token"

state =
	oauth_consumer_key: "05975fe90efaa64f2f545eb4ac774dc4"
	oauth_consumer_secret: "23bfcdd389b88937"

class VimeoTest extends interactive.InteractiveTest

	onSuccess: (params) ->
		@state.oauth_token = params.oauth_token
		@state.oauth_token_secret = params.oauth_token_secret

		this.fetchAndLog "http://vimeo.com/api/rest/v2?method=vimeo.test.login"

test = new VimeoTest(endpoints, state)
test.run()

