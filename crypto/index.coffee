# copyright 2013 wiz technologies inc.

require '..'
require './rsa'
require './x509'

wiz.package 'wiz.framework.crypto'

class wiz.framework.crypto

	@header: '-----BEGIN '
	@footer: '-----END '

	@types: [ #{{{
		wiz.framework.rsa.privateKey
		wiz.framework.rsa.publicKey
		wiz.framework.x509.certificate
	] #}}}

	@fromBuffer: (inBuffer) => #{{{ determine which type of object to create and create it
		out = []
		try
			# convert buffer to string
			input = inBuffer.toString("utf8")

			# split long string into array of lines
			lines = input.split('\n')

			# init vars
			str = undefined
			title = null

			# for each line
			for line, linenum in lines

				# ignore blank lines
				continue if line.length < 1

				# if a header is found
				if line[0..@header.length-1] is @header
					#wiz.log.debug "start #{line}"

					# read title ie. -----BEGIN RSA PRIVATE KEY-----
					title = line[@header.length..line.length-1-5] # 5 dashes

					# find title in array of possible object types
					throw "unknown object #{title}" unless type = new @detect(title)

					# set str to empty
					str = ''

				# if a footer is found
				else if line[0..@footer.length-1] is @footer
					#wiz.log.debug "end #{line}"

					# convert str to buffer
					buf = new Buffer(str, 'base64')

					# create object of detected type
					root = new type()

					# recursively parse child objects from buffer
					root.parseBuffer(buf, root)
					root.setValuesFromTree()

					# add the object to our output array
					out.push(root)

					# reset str var
					str = undefined

				# in between header and footer
				else if str?

					# append line to str
					str += line

				else

					throw "parse error on line #{linenum}"
		catch e
			wiz.log.err "parse error: #{e}"
			return null

		return out
	#}}}
	@detect: (title) => #{{{ get raw asn string
		return t if t.title is title for t in @types
		wiz.log.err "unknown crypto object"
		return null
	#}}}

# vim: foldmethod=marker wrap
