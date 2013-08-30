fs = require 'fs'

m = fs.readFileSync('mime').toString()

lines = m.split('\n')

for line in lines
	tabs = line.split('\t')
	for i in [1..tabs.length]
		if tabs[i] and tabs[i].length > 0
			exts = tabs[i].split(' ')
			for ext in exts
				console.log "'#{ext}': '#{tabs[0]}'"
