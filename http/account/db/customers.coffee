
# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../resource/base'
require '../../db/mongo'
require '../../../util/datetime'
require '../session'

wiz.package 'wiz.framework.http.account.db.customers'

# Example account entry:
#
#	{
#		"id" : "ROWB6S3IAE4O3RIQWUSA7DHVBLBH4II6BOM2M3XY3U7W7GU7PIV",
#		"type" : 'admin',
#		"data": {
#			"email" : "j@wiz.biz",
#			"fullname" : "J. Maurice",
#			"password" : "HVBLBH4II6BOM2M3XY3U7W7GU7PIVHVBLBH4II6BOM2M3XY3U7W",
#		}
#	}
#

class wiz.framework.http.account.db.customers extends wiz.framework.http.database.mongo.baseArray
	collectionName: 'customer'
	docKey: 'id'
	dataKey: 'data'
	emailKey: 'email'
	debug: true

	findOneByEmail: (req, res, email, cb) => #{{{
		@findOneByKey req, res, "#{@dataKey}.#{@emailKey}", email, @projection(), cb
	#}}}

	updateLastLoginTS: (req, res, cb) => #{{{
		if not req?.session?.account?.id?
			wiz.log.err "unable to update last login timestamp - session is null?"
			return
		now = wiz.framework.util.datetime.unixFullTS()
		@updateCustomDataByID req, res, req.session.account.id, 'lastLoginTS', now, cb
	#}}}

# vim: foldmethod=marker wrap
