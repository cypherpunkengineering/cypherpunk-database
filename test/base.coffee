require '..'

wiz.app 'testor'

class test extends wiz.base
	worker: () =>
		console.log 'this is a worker'

app = new test()
app.start()
