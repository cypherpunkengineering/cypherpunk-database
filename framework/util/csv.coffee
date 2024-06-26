# copyright 2013 J. Maurice <j@wiz.biz>

require '..'

wiz.package 'wiz.framework.util'

class wiz.framework.util.csv

	@parse = (str) ->
		arr = []
		quote = false # true means we're inside a quoted field

		# iterate over each character, keep track of current row and column (of the returned array)
		row = col = 0
		for c in [0..str.length]

			cc = str[c]			# current character
			nc = str[c+1]		#next character

			arr[row] = arr[row] || []			# create a new row if necessary
			arr[row][col] = arr[row][col] || ''	# create a new column (start with empty string) if necessary

			# If the current character is a quotation mark, and we're inside a
			# quoted field, and the next character is also a quotation mark,
			# add a quotation mark to the current column and skip the next character
			if (cc == '"' && quote && nc == '"')
				arr[row][col] += cc; ++c
				continue

			# If it's just one quotation mark, begin/end quoted field
			if (cc == '"')
				quote = !quote
				continue

			# If it's a comma and we're not in a quoted field, move on to the next column
			if (cc == ',' && !quote)
				++col
				continue

			# If it's a newline and we're not in a quoted field, move on to the next
			# row and move to column 0 of that new row
			if (cc == '\n' && !quote)
				++row
				col = 0
				continue

			# Otherwise, append the current character to the current column
			arr[row][col] += cc

		return arr

# vim: foldmethod=marker wrap
