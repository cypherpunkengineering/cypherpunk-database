require '..'
require '../util/sort'

wiz.app 'test'

data = [
	221234
	'13412342'
	431234
	'93422342'
	4
	'asdfads'
	32
	'93422342'
	'asdfads'
	11
	'asdfads'
	431234
	'asdfads'
	'foo2'
	'foo27'
	'foo2'
	'foo27'
	1
	71234
	'asdfads'
	5
	'12342'
	71234
	'13412342'
]

console.log data
data.sort wiz.framework.util.sort.natural
console.log data
