#/bin/sh
openssl genrsa -out wizkey.pem 2048
openssl req -new -key wizkey.pem -out wizcsr.pem
openssl x509 -req -days 9000 -in wizcsr.pem -signkey wizkey.pem -out wizcert.pem
