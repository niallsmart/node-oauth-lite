interactive = require('./interactive')

endpoints =
	request: "https://api.login.yahoo.com/oauth/v2/get_request_token"
	authorize: "https://api.login.yahoo.com/oauth/v2/request_auth"
	access: "https://api.login.yahoo.com/oauth/v2/get_token"

state =
	oauth_consumer_key: "dj0yJmk9YTRTdkV1V1pRcDlkJmQ9WVdrOWVrVmpOMU01TkdjbWNHbzlOakkyT1RZNE56WXkmcz1jb25zdW1lcnNlY3JldCZ4PWM5"
	oauth_consumer_secret: "8448cc7caf1f564af9d7e31bf3c5058841c107c1"

class YahooTest extends interactive.InteractiveTest

	onSuccess: (params) ->
		@state.oauth_token = params.oauth_token
		@state.oauth_token_secret = params.oauth_token_secret

		this.fetchAndLog "http://social.yahooapis.com/v1/user/#{params.xoauth_yahoo_guid}/profile/status?format=xml"

test = new YahooTest(endpoints, state)
test.run()

