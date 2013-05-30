#!/bin/sh
for i in connect-riak connect-s3store knox riak-js
do
	cd $i
	npm install -d
	cd -
done
