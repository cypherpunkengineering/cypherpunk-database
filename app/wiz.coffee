`var _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  _this = this;
`

require = () -> {}

wiz =
	package: (name) ->
		levels = name.split '.'
		space = window
		for ns, i in levels
			space[ns] = space[ns] or {}
			space = space[ns]

	getURL: () ->
		window.location.protocol + '//' + window.location.host + window.location.pathname

	getParentURL: (i = 1) ->
		url = wiz.getURL()
		while i > 0
			url = url.substring(0, url.lastIndexOf('/'))
			i = i -= 1
		return url

	getPath: () ->
		window.location.pathname

	getUrlVars: () ->
		vars = []
		hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')
		for i of hashes
			hash = hashes[i].split('=')
			vars.push(hash[0])
			vars[hash[0]] = hash[1]
		return vars

	getUrlVar: (name) ->
		return wiz.getUrlVars()[name]

	sessionDestroy: () ->
		sessionStorage.wiz = {}

	sessionSave: () ->
		sessionStorage.wiz = JSON.stringify(wiz.session)

	sessionLoad: () ->
		wiz.session = {}
		wiz.session = JSON.parse(sessionStorage.wiz) if sessionStorage.wiz?

wiz.sessionLoad()
