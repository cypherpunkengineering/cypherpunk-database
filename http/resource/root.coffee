# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require './base'
require './folder'

wiz.package 'wiz.framework.http.resource.root'

class wiz.framework.http.resource.root extends wiz.framework.http.resource.base

	init: () => #{{{
		super()
		@each (r) =>
			wiz.log.debug "loading router #{r.getFullPath()}" if @debug
			r.load()
		@each (r) =>
			wiz.log.debug "init router #{r.getFullPath()}" if @debug
			r.init()
	#}}}

class wiz.framework.http.resource.folderRoot extends wiz.framework.http.resource.folder

	init: () => #{{{
		super()
		@each (r) =>
			wiz.log.debug "loading router #{r.getFullPath()}" if @debug
			r.load()
		@each (r) =>
			wiz.log.debug "init router #{r.getFullPath()}" if @debug
			r.init()
	#}}}

# vim: foldmethod=marker wrap
