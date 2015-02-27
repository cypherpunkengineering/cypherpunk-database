# copyright 2013 J. Maurice <j@wiz.biz>

require '..'
require '../util/list'

wiz.app 'test'

class testNode extends wiz.framework.list.node
	constructor: (@value) ->
		super()

class testList extends wiz.framework.list.doublyList
	push: (n) =>
		super(n)
		console.log "pushed #{n.value}"

	remove: (n) =>
		super(n)
		console.log "removed #{n.value}"

	print: () =>
		console.log ''
		console.log 'list contents:'
		@each (n) => console.log n.value
		console.log ''

	deleteValue: (v) =>
		@each (n) =>
			list.remove n if n.value is v

list = new testList()

list.push new testNode(i) for i in [9..0]
list.print()
list.deleteValue(4)
list.deleteValue(7)
list.push new testNode(i.toString(16).toUpperCase()) for i in [15..10]
list.deleteValue('F')
list.deleteValue(0)
list.print()

# vim: foldmethod=marker wrap
