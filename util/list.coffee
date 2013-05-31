require '..'
require './list'
wiz.package 'wiz.framework.list'

class wiz.framework.list.node
	constructor: () ->
		@next = null
		@prev = null

class wiz.framework.list.tree extends wiz.framework.list.node
	constructor: () ->
		super()
		@root = null
		@length = 0

	push: (n) =>
		n.next = @root
		@root = n
		if n.next
			n.next.prev = n
		@length = @length + 1
		return n

	pop: (n) =>
		if n.prev
			n.prev.next = n.next
		else
			@root = n.next
			if n.next
				n.next.prev = null

		if n.next
			n.next.prev = n.prev

		@length = @length - 1

	each: (f) =>
		n = @root
		while n
			f(n)
			if n instanceof wiz.framework.list.tree
				n.each(f)
			n = n.next
