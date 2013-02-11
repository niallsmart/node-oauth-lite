express = require('express')
os = require("os")
oauth = require("oauth-lite")
urllib = require("url")
https = require("https")
querystring = require("querystring")

config =
	port: 8080
	consumer_key: "anonymous"
	consumer_secret: "anonymous"
	request_token_url: "https://www.google.com/accounts/OAuthGetRequestToken"
	authorize_token_url: "https://www.google.com/accounts/OAuthAuthorizeToken"
	access_token_url: "https://www.google.com/accounts/OAuthGetAccessToken"

app = express()

app.use(express.cookieParser())
app.use(express.cookieSession(
	secret: "4b5d8e07aaa69f2736d4"	# production apps shouldn't store OAuth tokens in cookies
));

fail = (res, err, status) ->
	console.error(err.stack or err)
	res.status(status or 500)
	res.send("An unexpected error occured (check console log).")

app.get "/oauth/callback", (req, res) ->

	for p in ["oauth_token", "oauth_verifier"]
		if !req.query[p]
			fail(res, "no #{p} specified in callback")
			return

	state = 
		oauth_consumer_key: config.consumer_key
		oauth_consumer_secret: config.consumer_secret
		oauth_token: req.query.oauth_token
		oauth_token_secret: req.session.oauth_token_secret
		oauth_verifier: req.query.oauth_verifier

	oauth.fetchAccessToken state, config.access_token_url, null, (err, params) ->
		if (err) 
			fail(res, err)
		else
			# save the access token to the session (production apps should
			# generally use a more secure persistence store than cookies)
			req.session.oauth_token = params.oauth_token
			req.session.oauth_token_secret = params.oauth_token_secret
			res.redirect "/user/info"

app.get "/login", (req, res) ->

	state = 
		oauth_consumer_key: config.consumer_key
		oauth_consumer_secret: config.consumer_secret
		oauth_callback: "http://localhost:#{config.port}/oauth/callback"

	form =
		xoauth_displayname: "node-oauth-lite"
		scope: "https://www.googleapis.com/auth/userinfo#email"

	oauth.fetchRequestToken state, config.request_token_url, form, (err, params) ->
		if (err) 
			fail(res, err)
		else
			req.session.oauth_token_secret = params.oauth_token_secret
			res.redirect config.authorize_token_url + "?oauth_token=#{params.oauth_token}"

app.get "/user/info", (req, res) ->

	state = 
		oauth_consumer_key: config.consumer_key
		oauth_consumer_secret: config.consumer_secret
		oauth_token: req.session.oauth_token
		oauth_token_secret: req.session.oauth_token_secret

	url = "https://www.googleapis.com/userinfo/email"

	options = urllib.parse(url, true);
	options.method = "GET"
	options.headers =
		"Authorization": oauth.makeAuthorizationHeader(state, options)

	https.get options, (hRes) ->
		if (hRes.statusCode != 200)
			fail(res, "authorized request failed with #{hRes.statusCode}")
		else
			buffer = new Buffer(0)
			hRes.on 'data', (chunk) ->
				buffer = Buffer.concat([buffer, chunk])
			hRes.on 'end', () ->
				details = querystring.parse(buffer.toString())
				res.send "hi there, #{details.email}!"

app.get "/*", (req, res) ->
	res.send("<a href='/login'>login</a>")

app.listen(config.port)
console.log "Listening - open http://localhost:#{config.port}"
