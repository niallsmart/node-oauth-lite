oauth = require("oauth-lite")
urllib = require('url')
request = require('request')

exports.InteractiveTest = class

	constructor: (@endpoints, @state, @form) ->
		null

	onSuccess: (params) ->
		console.log("authenticated:", params)

	makeAuthorizeUrl: (params) ->
		url = urllib.parse(@endpoints.authorize, true)
		url.query.oauth_token = params.oauth_token
		urllib.format(url)


	fetchAndLog: (url) ->
		options = urllib.parse(url, true);
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


	run: () ->

		options = urllib.parse(@endpoints.request, true)

		@state.oauth_callback = "oob"

		oauth.fetchRequestToken @state, options, @form, (err, params) =>

			if err
				console.trace(err.stack or err);
				process.exit(1)

			for own k, v of params
				@state[k] = v

			delete @state.oauth_callback
			delete @state.oauth_callback_confirmed

			console.log("")
			console.log("grant access at the URL below, then enter the")
			console.log("verification code displayed:")
			console.log("")
			console.log("\t#{this.makeAuthorizeUrl(params)}")
			console.log("")
			process.stdout.write("verification code> ")

			process.stdin.resume()
			process.stdin.setEncoding('utf8')

			process.stdin.on 'data', (chunk) =>
				process.stdin.pause()
				
				@state.oauth_verifier = chunk.trim()

				oauth.fetchAccessToken @state, @endpoints.access, null, (err, params) =>

					if err
						console.error(err.stack or err);
						process.exit(1)
									
					@onSuccess(params)