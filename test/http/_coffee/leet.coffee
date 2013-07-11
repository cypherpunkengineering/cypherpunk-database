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
