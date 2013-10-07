
# copyright 2013 wiz technologies inc.

require '../../..'
require '../../../crypto/otp'
require '../../../crypto/hash'
require '../../resource/base'
require '../../db/mongo'
require '../session'

wiz.package 'wiz.framework.http.acct.db.accounts'

class wiz.framework.http.acct.db.accounts extends wiz.framework.http.database.mongo.baseArray
	collectionName: 'accounts'
	docKey: 'email'
	debug: true

	list: (req, res) => #{{{
		@findOne req, res, @getDocKey(req.session.wiz.portal), @getArrayKey(), (results) =>
			userData = []
			if not results or not results[@arrayKey] or not results[@arrayKey].length > 0
				return @listResponse(req, res, userData)

			results[@arrayKey].sort (a, b) =>
				if a[@elementKey] and b[@elementKey]
					return -1 if a[@elementKey] < b[@elementKey]
					return 1 if a[@elementKey] > b[@elementKey]
				return 0

			for result in results[@arrayKey]
				userData.push
					DT_RowId : result.id
					0 : result.id || 'unknown'
					1 : result.fullname || ''
					2 : result.email || ''
					3 : result.level || 0
					4 : result.created || 0
					5 : result.updated || 0

			@listResponse(req, res, userData)
	#}}}
	insert: (req, res) => #{{{
		powerLevels = {}
		powerLevels[l] = pl for l of @server.powerLevel when pl = @server.powerLevel[l]
		return unless recordToInsert = wiz.portal.admin.entity.user.fromUser(req, res, powerLevels, req.body.fullname, req.body.email, req.body.pass, req.body.level)

		@insertOne req, res, req.session.wiz.portal, recordToInsert
	#}}}
	modify: (req, res) => #{{{
		return res.send 501 # TODO: implement user modify
	#}}}
	drop: (req, res) => #{{{
		# TODO: need extensible method (send event?) for other modules to delete related objects from their databases onUserDeleted
		return res.send 400 if not recordsToDelete = req.body.recordsToDelete or typeof recordsToDelete isnt 'object' # only proceed if object
		@dropMany req, res, req.session.wiz.portal, null, recordsToDelete
	#}}}

	findOneByEmail: (req, res, email, cb) => #{{{
		query = @getDocKey(email)
		fields = @fields()
		@findOne req, res, query, fields, cb
	#}}}

# vim: foldmethod=marker wrap
