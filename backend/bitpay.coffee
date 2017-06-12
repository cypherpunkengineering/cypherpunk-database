require './_framework'
require './_framework/thirdparty/bitpay'

wiz.package 'cypherpunk.backend.bitpay'

class cypherpunk.backend.bitpay extends wiz.framework.thirdparty.bitpay

#  { status: 'confirmed',
#    exceptionStatus: false,
#    amount: '11.95',
#    rate: '2802.74',
#    action: 'invoiceStatus',
#    btcPaid: '0.004264',
#    currency: 'USD',
#    posData: '{"plan":"monthly"}' }

	onVerify: (data) =>
		@server.root.slack.notify("[TEST] BitPay IPN #{data?.action} (#{data?.invoice_id}) is #{data?.status} for #{data?.btcPaid} BTC (#{data?.amount} USD)")

# vim: foldmethod=marker wrap
