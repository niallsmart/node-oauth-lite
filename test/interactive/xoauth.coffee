urllib = require('url')
oauth = require('../../src/http')
prim = require('../../src/prim')

state =
	oauth_consumer_key: "anonymous"
	oauth_consumer_secret: "anonymous"
	oauth_token: '1/EQPz_bOI3lPeZzO2LFnyO1Mryc-NX1bzKQ5iYMjkZ4k'
	oauth_token_secret: 'SAiOi289KVoKr4Bwm7WvxpjD'

url = "https://mail.google.com/mail/b/niall.smart@gmail.com/smtp/"
url = "https://mail.google.com/mail/b/default/smtp/"
request = urllib.parse(url, true)
request.method = "GET"

params = oauth.makeAuthorizationHeader state, request

params = params[6..]

xoauth = "GET #{url} #{params}"

console.log ""
console.log "#{xoauth}"
console.log ""
console.log new Buffer(xoauth).toString('base64')
console.log ""

xoauth = "R0VUIGh0dHBzOi8vbWFpbC5nb29nbGUuY29tL21haWwvYi9zb21ldXNlckBleGF
tcGxlLmNvbS9pbWFwLz94b2F1dGhfcmVxdWVzdG9yX2lkPXNvbWV1c2VyJTQwZX
hhbXBsZS5jb20gb2F1dGhfY29uc3VtZXJfa2V5PSJleGFtcGxlLmNvbSIsb2F1d
Ghfbm9uY2U9IjQ3MTAzMDczMjc5MjU0Mzk0NTEiLG9hdXRoX3NpZ25hdHVyZT0i
NzUlMkJCNjNOYlcyR2RETWFPQ0VkJTJGeSUyRmIlMkIwUWslM0QiLG9hdXRoX3N
pZ25hdHVyZV9tZXRob2Q9IkhNQUMtU0hBMSIsb2F1dGhfdGltZXN0YW1wPSIxMj
YwOTMzNjgzIixvYXV0aF92ZXJzaW9uPSIxLjAiCg=="

console.log ""
console.log new Buffer(xoauth, 'base64').toString()
console.log ""