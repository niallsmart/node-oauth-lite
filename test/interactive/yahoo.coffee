interactive = require('./interactive')

endpoints =
	request: "https://api.login.yahoo.com/oauth/v2/get_request_token"
	authorize: "https://api.login.yahoo.com/oauth/v2/request_auth"
	access: "https://api.login.yahoo.com/oauth/v2/get_token"

state =
	oauth_consumer_key: "dj0yJmk9b2Iwc2EzVGZpcDV1JmQ9WVdrOWVrVmpOMU01TkdjbWNHbzlOakkyT1RZNE56WXkmcz1jb25zdW1lcnNlY3JldCZ4PTJi"
	oauth_consumer_secret: "74f2ed34c3c34159d685946ce9adee83358c4faa"

class YahooTest extends interactive.InteractiveTest

	onSuccess: (params) ->
		@state.oauth_token = params.oauth_token
		@state.oauth_token_secret = params.oauth_token_secret

		this.fetchAndLog "http://query.yahooapis.com/v1/yql?format=json&q=SELECT+*+FROM+social.profile+WHERE+guid=me"

test = new YahooTest(endpoints, state)
test.run()

