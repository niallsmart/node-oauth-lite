interactive = require('./interactive')
oauth = require("oauth-lite")
Imap = require('imap')
urllib = require('url')

endpoints =
	request: "https://www.google.com/accounts/OAuthGetRequestToken"
	authorize: "https://www.google.com/accounts/OAuthAuthorizeToken"
	access: "https://www.google.com/accounts/OAuthGetAccessToken"

state =
	oauth_consumer_key: "anonymous"
	oauth_consumer_secret: "anonymous"

form =
	xoauth_displayname: "node-oauth-lite"
	scope: "https://mail.google.com"

class GmailTest extends interactive.InteractiveTest

	constructor: (@email, @endpoints, @state, @form) ->
		null

	onSuccess: (params) ->
		@state.oauth_token = params.oauth_token
		@state.oauth_token_secret = params.oauth_token_secret

		options = "https://mail.google.com/mail/b/#{@email}/imap/"
		options = urllib.parse(options)
		options.method = "GET"
		icr = oauth.makeClientInitialResponse(state, options)

		imap = new Imap(
			xoauth: icr
			host: 'imap.gmail.com',
			port: 993,
			secure: true
		)

		imap.connect (err) ->
			if (err)
				console.log("IMAP connect failed", err)
				return
			console.log("connected to IMAP server")
			imap.openBox 'INBOX', true, (err, info) ->
				if (!err)
					console.log("#{info.messages.total} messages(s) in INBOX");
				imap.logout();

console.log("")
console.log("enter your GMail address")
console.log("")
process.stdout.write("> ")

process.stdin.once 'data', (chunk) =>
	process.stdin.pause()
	email = chunk.trim()
	test = new GmailTest(email, endpoints, state, form)
	test.run()

process.stdin.setEncoding('utf8')
process.stdin.resume()
