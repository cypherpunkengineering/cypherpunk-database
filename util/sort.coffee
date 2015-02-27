# copyright 2013 J. Maurice <j@wiz.biz>

require '..'

wiz.package 'wiz.framework.util'

class wiz.framework.util.sort

	@natural = (a, b) ->
		a = a.toString() if typeof a is 'number'
		b = b.toString() if typeof b is 'number'
		aa = a.split(/(\d+)/)
		bb = b.split(/(\d+)/)
		x = 0

		while x < Math.max(aa.length, bb.length)
			unless aa[x] is bb[x]
				cmp1 = (if (isNaN(parseInt(aa[x], 10))) then aa[x] else parseInt(aa[x], 10))
				cmp2 = (if (isNaN(parseInt(bb[x], 10))) then bb[x] else parseInt(bb[x], 10))
				if cmp1 is `undefined` or cmp2 is `undefined`
					return aa.length - bb.length
				else
					return (if (cmp1 < cmp2) then -1 else 1)
			x++
		return 0

# vim: foldmethod=marker wrap
