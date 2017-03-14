require './_framework'
require './_framework/http/resource/base'
require './_framework/http/db/mysql'

wiz.package 'cypherpunk.backend.db.smartdns'

class cypherpunk.backend.db.smartdns extends wiz.framework.http.database.mysql.driver

	tables: #{{{
		servers: 'servers'
	#}}}

	_queryServerInsert: (req, res, server, ipaddress, cb1) => #{{{ insert into servers (server, ipaddress) values ('<server>', '<ipaddress>')
		return cb1("missing parameters") if not server? or not ipaddress?
		q = "INSERT INTO #{@tables.servers} (server, ipaddress) "
		q += " VALUES ('#{server}', '#{ipaddress}')"
		@query req, res, q, (req, res, err, rows, fields) =>
			cb1(err)
	#}}}

	serverInsert: (req, res, server, ipaddress, cb8) => #{{{
		@_queryServerInsert req, res, server, ipaddress, (err) =>
			cb8(req, res, err)
	#}}}

# vim: foldmethod=marker wrap
