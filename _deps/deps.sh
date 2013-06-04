#!/bin/sh
for i in knox
do
	cd $i
	npm install -d
	cd -
done
