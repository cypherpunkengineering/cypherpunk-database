require '..'
require './list'
wiz.package 'wiz.framework.list'

class wiz.framework.list.doublyList
	constructor: () ->
		@nodes = 0
		@head = null
		@tail = null

	# add a node to the start of the list
	push: (n) =>
		n.next = @head
		@head = n
		if n.next?
			n.next.prev = n
		else
			@tail = n
		@nodes = @nodes + 1
		return n

	# remove a node from anywhere in the list (note that n *must* be a valid node in the list)
	remove: (n) =>
		if n.prev?
			n.prev.next = n.next
		else
			@head = n.next

		if n.next?
			n.next.prev = n.prev
		else
			@tail = n.prev

		@nodes = @nodes - 1

	each: (f) =>
		n = @head
		while n
			f(n)
			n = n.next

class wiz.framework.list.branchList extends wiz.framework.list.doublyList
	each: (f) =>
		n = @head
		while n
			f(n)
			if n instanceof wiz.framework.list.tree
				n.each(f)
			n = n.next

class wiz.framework.list.node
	constructor: () ->
		@next = null
		@prev = null

# a tree is a node with a parent node and a list of child branches
# the root branch of the tree has no parent (the 'trunk')
class wiz.framework.list.tree extends wiz.framework.list.node
	constructor: (@parent) ->
		@branchList = new wiz.framework.list.branchList()

	branchAdd: (l) =>
		@branchList.push l
		return l

	each: (f) =>
		@branchList.each(f)

# vim: foldmethod=marker wrap
