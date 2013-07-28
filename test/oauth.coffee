require '..'
require '../http/oauth'

fs = require 'fs'

wiz.app 'test'

oauth = new wiz.framework.http.oauth.twitter
	consumerKey: fs.readFileSync('OAuthkey').toString()
	consumerSecret: fs.readFileSync('OAuthsecret').toString()

oauth.requestToken 'test', (bar) =>
	console.log bar
