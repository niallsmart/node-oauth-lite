urllib = require('url')
oauth = require('../../src/http')

endpoints =
	request: "https://www.google.com/accounts/OAuthGetRequestToken"
	authorize: "https://www.google.com/accounts/OAuthAuthorizeToken"
	access: "https://www.google.com/accounts/OAuthGetAccessToken"

state =
	oauth_consumer_key: "anonymous"
	oauth_consumer_secret: "anonymous"
	oauth_callback: "oob"

request = urllib.parse(endpoints.request, true)

form =
	xoauth_displayname: "OAuth Lite"
	scope: "http://www.google.com/calendar/feeds http://picasaweb.google.com/data"

oauth.fetchRequestToken state, request, form, (err, params) ->

	if err
		console.error(err);
		node.exit(1)

	for own k, v of params
		state[k] = v

	delete state.oauth_callback
	delete state.oauth_callback_confirmed

	redirect = urllib.parse(endpoints.authorize, true)
	redirect.query.oauth_token = params.oauth_token

	console.log("grant access at the URL below, then enter the verification code displayed:")
	console.log("")
	console.log("\t#{urllib.format(redirect)}")
	console.log("")
	process.stdout.write("code> ")

	process.stdin.resume()
	process.stdin.setEncoding('utf8')

	process.stdin.on 'data', (chunk) ->
		process.stdin.pause()
		
		state.oauth_verifier = chunk.trim()

		oauth.fetchAccessToken state, endpoints.access, null, (err, params) ->
			console.log(arguments)

