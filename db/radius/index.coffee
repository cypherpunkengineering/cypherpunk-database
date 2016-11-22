require './_framework'
require './_framework/http/resource/base'
require './_framework/http/db/mysql'

wiz.package 'cypherpunk.backend.db.radius'

class cypherpunk.backend.db.radius extends wiz.framework.http.database.mysql.driver

	tables: #{{{
		check: 'radcheck'
		usergroup: 'radusergroup'
	#}}}
	groups: #{{{
		free:
			name: 'free'
			priority: '1'
		premium:
			name: 'premium'
			priority: '2'
		developer:
			name: 'developer'
			priority: '42'
	#}}}

	_queryInsertCheck: (req, res, id, username, password, cb1) => #{{{ insert into radcheck (username, attribute, op, value) values ('<username>', 'NT-Password', ':=', '<NTPASSWORDHASH>')
		return cb1("missing parameters") if not id? or not username? or not password?
		q = "REPLACE INTO #{@tables.check} (account, username, attribute, op, value) "
		q += " VALUES ('#{id}', '#{username}', 'Cleartext-Password', ':=', '#{password}')"
		@query req, res, q, (req, res, err, rows, fields) =>
			cb1(err)
	#}}}
	_queryDeleteCheck: (req, res, id, cb2) => #{{{ delete from radcheck where id = 'X'
		return cb2("missing parameters") if not id?
		q = "DELETE FROM #{@tables.check} WHERE `account` = '#{id}'"
		@query req, res, q, (req, res, err, rows, fields) =>
			cb2(err)
	#}}}

	_queryInsertUsergroup: (req, res, username, groupname, priority, cb3) => #{{{
		return cb3("missing parameters") if not username? or not groupname? or not priority?
		q = "REPLACE INTO #{@tables.usergroup} (username, groupname, priority) "
		q += " VALUES ('#{username}', '#{groupname}', '#{priority}')"
		@query req, res, q, (req, res, err, rows, fields) =>
			cb3(err)
	#}}}
	_queryDeleteUsergroup: (req, res, username, cb4) => #{{{
		return cb4("missing parameters") if not username?
		q = "DELETE FROM #{@tables.usergroup} WHERE `username` = '#{username}'"
		@query req, res, q, (req, res, err, rows, fields) =>
			cb4(err)
	#}}}

	_grantUserGroup: (req, res, account, group, cb5) => #{{{
		@_queryInsertCheck req, res, account?.id, account?.privacy?.username, account?.privacy?.password, (err) =>
			return cb5(err) if err?
			@_queryInsertUsergroup req, res, account?.privacy?.username, group.name, group.priority, (err) =>
				cb5(err)
	#}}}
	_revokeUserAll: (req, res, account, cb6) => #{{{
		@_queryDeleteCheck req, res, account?.id, (err) =>
			return cb6(err) if err?
			@_queryDeleteUsergroup req, res, account?.privacy?.username, (err) =>
				cb6(err)
	#}}}

	_grantAccess: (req, res, account, group, cb7) => #{{{ recursive method to grant user group and all lower groups
		# don't grant any access if account not confirmed
		return cb7() if account.data.confirmed.toString() == "false"
		return cb7() if not group?.name?

		# update access based on group
		switch group.name

			when @groups.free.name
				@_grantUserGroup req, res, account, @groups.free, (err) =>
					cb7(err)

			when @groups.premium.name
				@_grantAccess req, res, account, @groups.free, (err) =>
					return cb7(err) if err?
					@_grantUserGroup req, res, account, @groups.premium, (err) =>
						cb7(err)

			when @groups.developer.name
				@_grantAccess req, res, account, @groups.premium, (err) =>
					return cb7(err) if err?
					@_grantUserGroup req, res, account, @groups.developer, (err) =>
						cb7(err)
	#}}}

	updateUserAccess: (req, res, account, cb8) => #{{{
		@_revokeUserAll req, res, account, (err) =>
			return cb8(err) if err?
			@_grantAccess req, res, account, @groups[account.type], (err) =>
				cb8(err)
	#}}}

# vim: foldmethod=marker wrap
