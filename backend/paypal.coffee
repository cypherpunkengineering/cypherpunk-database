require './_framework'
require './_framework/thirdparty/paypal'

wiz.package 'cypherpunk.backend.paypal'

class cypherpunk.backend.paypal extends wiz.framework.thirdparty.paypal

# { txn_type: 'subscr_signup',
#   subscr_id: 'I-8CW0MKVN2BSB',
#   last_name: 'buyer',
#   residence_country: 'US',
#   mc_currency: 'USD',
#   item_name: 'Premium Access to Cypherpunk Privacy',
#   business: 'paypaltest-facilitator@cypherpunk.com',
#   amount3: '69.00',
#   recurring: '1',
#   verify_sign: 'AiKZhEEPLJjSIccz.2M.tbyW5YFwAcJXHPGEHeamGexDe37weJlYZj-.',
#   payer_status: 'verified',
#   test_ipn: '1',
#   payer_email: 'paypaltest-buyer@cypherpunk.com',
#   first_name: 'test',
#   receiver_email: 'paypaltest-facilitator@cypherpunk.com',
#   payer_id: 'SR5VZMWJRMJLL',
#   reattempt: '1',
#   item_number: 'annually6900',
#   subscr_date: '06:58:55 Jun 09, 2017 PDT',
#   btn_id: '3666714',
#   custom: '{"id":"GPWECL42ESOTMVUWYEAPGVR56JCCIEWM5HR62GD4EHSQ35EVRQS","plan":"annually"}',
#   charset: 'windows-1252',
#   notify_version: '3.8',
#   period3: '12 M',
#   mc_amount3: '69.00',
#   ipn_track_id: 'c69f42b7d3f0f' }

	onVerify: (data) =>
		@server.root.slack.notify("[TEST] PayPal IPN #{data?.txn_type} by #{data?.payer_email} (#{data?.payer_status}) to #{data?.item_number} for #{data?.amount3} (#{data?.period3})")

# vim: foldmethod=marker wrap
